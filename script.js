// ===== PANTRY PAL - POLISHED VERSION =====
// Modern, robust, and feature-complete smart fridge application

// ===== GLOBAL STATE AND CONFIGURATION =====
let userDatabase = {};
let currentUserEmail = null;
let swiper = null;
let isLoading = false;

// Configuration
const CONFIG = {
    API_KEY: "", // Placeholder - would be set from environment in production
    API_URL: "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent",
    STORAGE_KEY: "pantrypal_data",
    MAX_RETRIES: 3,
    TOAST_DURATION: 4000
};

// ===== FOOD ICONS AND CATEGORIES =====
const foodIcons = {
    apple: `<svg class="h-10 w-10 text-red-500 pointer-events-none" viewBox="0 0 20 20" fill="currentColor">
        <path fill-rule="evenodd" d="M10 2a4 4 0 00-4 4v1h8V6a4 4 0 00-4-4zM4.5 9.5A2.5 2.5 0 007 12h6a2.5 2.5 0 002.5-2.5V9h-11v.5zM3 13.5A2.5 2.5 0 005.5 16h9a2.5 2.5 0 002.5-2.5V13H3v.5z" clip-rule="evenodd" />
    </svg>`,
    milk: `<svg class="h-10 w-10 text-blue-100 pointer-events-none" viewBox="0 0 20 20" fill="currentColor">
        <path d="M5 3a1 1 0 000 2h10a1 1 0 100-2H5z" />
        <path fill-rule="evenodd" d="M4 6h12v10a2 2 0 01-2 2H6a2 2 0 01-2-2V6zm2 2a1 1 0 00-1 1v1a1 1 0 102 0V9a1 1 0 00-1-1z" clip-rule="evenodd" />
    </svg>`,
    meat: `<svg class="h-10 w-10 text-red-300 pointer-events-none" viewBox="0 0 20 20" fill="currentColor">
        <path d="M11 3a1 1 0 10-2 0v1.586l-4.293-4.293a1 1 0 00-1.414 1.414L7.586 6H3a1 1 0 000 2h4.586l-4.293 4.293a1 1 0 101.414 1.414L9 9.414V17a1 1 0 102 0V9.414l4.293 4.293a1 1 0 001.414-1.414L12.414 8H17a1 1 0 100-2h-4.586l4.293-4.293a1 1 0 00-1.414-1.414L11 4.586V3z" />
    </svg>`,
    egg: `<svg class="h-10 w-10 text-yellow-100 pointer-events-none" viewBox="0 0 20 20" fill="currentColor">
        <path d="M10 4a6 6 0 100 12 6 6 0 000-12z" />
    </svg>`,
    leaf: `<svg class="h-10 w-10 text-green-300 pointer-events-none" viewBox="0 0 20 20" fill="currentColor">
        <path d="M17.293 4.293a1 1 0 010 1.414l-8.586 8.586a1 1 0 01-1.414 0L2.707 9.707a1 1 0 011.414-1.414L9 12.586l7.293-7.293a1 1 0 011.414 0z" />
    </svg>`,
    cheese: `<svg class="h-10 w-10 text-yellow-300 pointer-events-none" viewBox="0 0 20 20" fill="currentColor">
        <path d="M2 6a2 2 0 012-2h12a2 2 0 012 2v2a2 2 0 01-2 2H4a2 2 0 01-2-2V6z" />
        <path d="M3 12a1 1 0 011-1h12a1 1 0 110 2H4a1 1 0 01-1-1z" />
    </svg>`,
    default: `<svg class="h-10 w-10 text-gray-400 pointer-events-none" viewBox="0 0 20 20" fill="currentColor">
        <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd" />
    </svg>`
};

const iconCategories = ['apple', 'milk', 'meat', 'egg', 'leaf', 'cheese', 'default'];

// ===== UTILITY FUNCTIONS =====

/**
 * Show loading screen with optional message
 */
function showLoading(message = "Loading...") {
    const loadingScreen = document.getElementById('loading-screen');
    const loadingText = loadingScreen.querySelector('p');
    if (loadingText) loadingText.textContent = message;
    loadingScreen.style.display = 'flex';
    isLoading = true;
}

/**
 * Hide loading screen
 */
function hideLoading() {
    const loadingScreen = document.getElementById('loading-screen');
    loadingScreen.style.display = 'none';
    isLoading = false;
}

/**
 * Show toast notification
 */
function showToast(message, type = 'info', duration = CONFIG.TOAST_DURATION) {
    const container = document.getElementById('toast-container');
    const toast = document.createElement('div');
    toast.className = `toast ${type}`;
    toast.innerHTML = `
        <div class="flex items-center justify-between">
            <span>${message}</span>
            <button onclick="this.parentElement.parentElement.remove()" class="ml-4 text-lg">&times;</button>
        </div>
    `;
    
    container.appendChild(toast);
    
    // Trigger animation
    setTimeout(() => toast.classList.add('show'), 10);
    
    // Auto remove
    setTimeout(() => {
        toast.classList.remove('show');
        setTimeout(() => toast.remove(), 300);
    }, duration);
}

/**
 * Validate email format
 */
function isValidEmail(email) {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
}

/**
 * Validate password strength
 */
function validatePassword(password) {
    const minLength = 8;
    const hasUpperCase = /[A-Z]/.test(password);
    const hasLowerCase = /[a-z]/.test(password);
    const hasNumbers = /\d/.test(password);
    
    return {
        isValid: password.length >= minLength && hasUpperCase && hasLowerCase && hasNumbers,
        message: password.length < minLength ? 
            `Password must be at least ${minLength} characters long` :
            !hasUpperCase ? 'Password must contain uppercase letters' :
            !hasLowerCase ? 'Password must contain lowercase letters' :
            !hasNumbers ? 'Password must contain numbers' : ''
    };
}

/**
 * Generate unique ID
 */
function generateId() {
    return Date.now().toString(36) + Math.random().toString(36).substr(2);
}

/**
 * Save data to localStorage
 */
function saveToStorage() {
    try {
        localStorage.setItem(CONFIG.STORAGE_KEY, JSON.stringify({
            userDatabase,
            currentUserEmail
        }));
    } catch (error) {
        console.error('Failed to save to localStorage:', error);
        showToast('Failed to save data locally', 'error');
    }
}

/**
 * Load data from localStorage
 */
function loadFromStorage() {
    try {
        const data = localStorage.getItem(CONFIG.STORAGE_KEY);
        if (data) {
            const parsed = JSON.parse(data);
            userDatabase = parsed.userDatabase || {};
            currentUserEmail = parsed.currentUserEmail || null;
            return true;
        }
    } catch (error) {
        console.error('Failed to load from localStorage:', error);
        showToast('Failed to load saved data', 'warning');
    }
    return false;
}

// ===== API FUNCTIONS =====

/**
 * Call Gemini API with retry logic and error handling
 */
async function callGemini(payload, retries = CONFIG.MAX_RETRIES) {
    if (!CONFIG.API_KEY) {
        throw new Error('API key not configured');
    }
    
    try {
        const response = await fetch(`${CONFIG.API_URL}?key=${CONFIG.API_KEY}`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(payload)
        });
        
        if (!response.ok) {
            throw new Error(`API request failed: ${response.status} ${response.statusText}`);
        }
        
        return await response.json();
    } catch (error) {
        console.error('Gemini API call failed:', error);
        
        if (retries > 0) {
            console.log(`Retrying API call... (${retries} attempts remaining)`);
            await new Promise(resolve => setTimeout(resolve, 1000));
            return callGemini(payload, retries - 1);
        }
        
        throw error;
    }
}

/**
 * Get icon and category for food item using AI (stubbed for now)
 */
async function getIconAndCategory(itemName) {
    // Simulate API delay
    await new Promise(resolve => setTimeout(resolve, 500));
    
    // Simple categorization logic (would be AI-powered in production)
    const name = itemName.toLowerCase();
    
    if (name.includes('apple') || name.includes('fruit')) return { icon: 'apple', category: 'Fruits' };
    if (name.includes('milk') || name.includes('dairy')) return { icon: 'milk', category: 'Dairy & Cheeses' };
    if (name.includes('meat') || name.includes('chicken') || name.includes('beef')) return { icon: 'meat', category: 'Meats' };
    if (name.includes('egg')) return { icon: 'egg', category: 'Dairy & Cheeses' };
    if (name.includes('vegetable') || name.includes('lettuce') || name.includes('carrot')) return { icon: 'leaf', category: 'Vegetables' };
    if (name.includes('cheese')) return { icon: 'cheese', category: 'Dairy & Cheeses' };
    
    return { icon: 'default', category: 'Other' };
}

/**
 * Generate recipes based on available ingredients
 */
async function getRecipes(mood = 'any') {
    const foodItems = userDatabase[currentUserEmail]?.foodItems || [];
    
    if (foodItems.length === 0) {
        return {
            recipes: [{
                title: "Stock Up First!",
                description: "Add some ingredients to your fridge to get personalized recipe suggestions.",
                ingredients: [],
                instructions: ["Visit your local grocery store", "Add items to your Pantry Pal", "Come back for amazing recipes!"]
            }]
        };
    }
    
    // Simulate API call with realistic delay
    await new Promise(resolve => setTimeout(resolve, 2000));
    
    // Generate mock recipes based on available ingredients
    const availableIngredients = foodItems.map(item => item.name);
    const sampleRecipes = [
        {
            title: "Fresh Garden Salad",
            description: "A crisp and refreshing salad perfect for any meal",
            ingredients: availableIngredients.slice(0, 3),
            instructions: [
                "Wash and chop all vegetables",
                "Mix in a large bowl",
                "Add your favorite dressing",
                "Serve immediately"
            ]
        },
        {
            title: "Quick Stir Fry",
            description: "A fast and nutritious meal using your fresh ingredients",
            ingredients: availableIngredients.slice(0, 4),
            instructions: [
                "Heat oil in a large pan",
                "Add ingredients in order of cooking time",
                "Stir frequently for 5-7 minutes",
                "Season to taste and serve"
            ]
        }
    ];
    
    return { recipes: sampleRecipes };
}

// ===== FOOD ITEM MANAGEMENT =====

/**
 * Get expiration information and styling for food item
 */
function getExpirationInfo(item) {
    if (!item.expirationDate) {
        return { status: 'unknown', borderClass: 'border-glow-gray', message: 'No expiration date' };
    }
    
    const now = new Date();
    const expiration = new Date(item.expirationDate);
    const daysUntilExpiration = Math.ceil((expiration - now) / (1000 * 60 * 60 * 24));
    
    if (daysUntilExpiration < 0) {
        return { status: 'expired', borderClass: 'border-glow-red', message: 'Expired' };
    } else if (daysUntilExpiration <= 2) {
        return { status: 'expiring', borderClass: 'border-glow-yellow', message: `Expires in ${daysUntilExpiration} day${daysUntilExpiration === 1 ? '' : 's'}` };
    } else if (daysUntilExpiration <= 7) {
        return { status: 'fresh', borderClass: 'border-glow-green', message: `Expires in ${daysUntilExpiration} days` };
    } else {
        return { status: 'very-fresh', borderClass: 'border-glow-green', message: `Fresh for ${daysUntilExpiration} days` };
    }
}

// ===== FRIDGE RENDERING =====

/**
 * Render the main fridge interface with Swiper
 */
function renderFridge() {
    // Destroy existing swiper instance
    if (swiper) {
        swiper.destroy(true, true);
        swiper = null;
    }
    
    const foodItems = userDatabase[currentUserEmail]?.foodItems || [];
    const fridgeContentArea = document.getElementById('fridge-content-area');
    
    // Create swiper container
    const fridgeHTML = `
        <div id="fridge-swiper" class="swiper h-full w-full">
            <div id="fridge-pages-wrapper" class="swiper-wrapper"></div>
            <div class="swiper-pagination"></div>
        </div>
    `;
    fridgeContentArea.innerHTML = fridgeHTML;
    
    const wrapper = document.getElementById('fridge-pages-wrapper');
    
    // Handle empty fridge
    if (foodItems.length === 0) {
        const emptySlide = createEmptyFridgeSlide();
        wrapper.appendChild(emptySlide);
    } else {
        // Group items by category
        const groupedItems = groupItemsByCategory(foodItems);
        
        // Create slides for each category
        const categoryOrder = ['Meats', 'Dairy & Cheeses', 'Fruits', 'Vegetables', 'Grains', 'Beverages', 'Other'];
        categoryOrder.forEach(category => {
            if (groupedItems[category]) {
                const slide = createCategorySlide(category, groupedItems[category]);
                wrapper.appendChild(slide);
            }
        });
    }
    
    // Initialize Swiper
    initializeSwiper();
}

/**
 * Create empty fridge slide
 */
function createEmptyFridgeSlide() {
    const slide = document.createElement('div');
    slide.className = 'swiper-slide flex flex-col items-center justify-center text-center h-full';
    slide.innerHTML = `
        <svg class="w-24 h-24 text-amber-700/50 mb-4" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" d="M8.25 7.5l.415-.207a.75.75 0 011.085.67V10.5m0 0h6m-6 0a.75.75 0 001.085.67l.415-.207M3 7.5v10.5A2.25 2.25 0 005.25 20h13.5A2.25 2.25 0 0021 17.5V7.5M6 18.75a.75.75 0 11-1.5 0 .75.75 0 011.5 0z" />
        </svg>
        <p class="text-3xl font-semibold fun-font text-amber-800 mb-4">Your fridge is sparkling clean!</p>
        <p class="text-amber-700 mb-8">Tap the '+' cube to add your first item.</p>
        <div class="flex justify-center">
            <div data-action="add" class="ice-cube add-cube rounded-3xl w-24 h-24 md:w-28 md:h-28 flex items-center justify-center cursor-pointer">
                <svg class="w-10 h-10 text-gray-400 pointer-events-none" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6"></path>
                </svg>
            </div>
        </div>
    `;
    return slide;
}

/**
 * Group food items by category
 */
function groupItemsByCategory(foodItems) {
    return foodItems.reduce((acc, item) => {
        const category = item.category || 'Other';
        if (!acc[category]) acc[category] = [];
        acc[category].push(item);
        return acc;
    }, {});
}

/**
 * Create category slide
 */
function createCategorySlide(category, items) {
    const slide = document.createElement('div');
    slide.className = 'swiper-slide flex flex-col items-center p-4';
    
    // Category header
    const header = document.createElement('h2');
    header.className = 'text-3xl font-bold text-amber-800 mb-4 fun-font fade-in';
    header.textContent = category;
    slide.appendChild(header);
    
    // Items grid
    const grid = document.createElement('div');
    grid.className = 'grid grid-cols-3 sm:grid-cols-5 gap-4 w-full max-w-4xl';
    
    // Add existing items
    items.forEach(item => {
        const iceCube = createItemCube(item);
        grid.appendChild(iceCube);
    });
    
    // Add "+" cube
    const addCube = createAddCube();
    grid.appendChild(addCube);
    
    slide.appendChild(grid);
    return slide;
}

/**
 * Create item cube element
 */
function createItemCube(item) {
    const iceCube = document.createElement('div');
    iceCube.className = 'ice-cube rounded-3xl aspect-square flex items-center justify-center cursor-pointer';
    iceCube.dataset.action = 'details';
    iceCube.dataset.itemId = item.id;
    iceCube.setAttribute('tabindex', '0');
    iceCube.setAttribute('role', 'button');
    iceCube.setAttribute('aria-label', `View details for ${item.name}`);
    
    const { borderClass } = getExpirationInfo(item);
    iceCube.classList.add(borderClass);
    
    iceCube.innerHTML = `
        <div class="item-added pointer-events-none">
            ${foodIcons[item.icon] || foodIcons['default']}
        </div>
    `;
    
    return iceCube;
}

/**
 * Create add item cube
 */
function createAddCube() {
    const addCube = document.createElement('div');
    addCube.className = 'ice-cube add-cube rounded-3xl aspect-square flex items-center justify-center';
    addCube.dataset.action = 'add';
    addCube.setAttribute('tabindex', '0');
    addCube.setAttribute('role', 'button');
    addCube.setAttribute('aria-label', 'Add new item');
    
    addCube.innerHTML = `
        <svg class="w-10 h-10 text-gray-400 pointer-events-none" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6"></path>
        </svg>
    `;
    
    return addCube;
}

/**
 * Initialize Swiper with configuration
 */
function initializeSwiper() {
    try {
        swiper = new Swiper('.swiper', {
            direction: 'horizontal',
            loop: false,
            pagination: {
                el: '.swiper-pagination',
                clickable: true
            },
            keyboard: {
                enabled: true,
            },
            a11y: {
                enabled: true,
            },
            breakpoints: {
                640: {
                    slidesPerView: 1,
                },
                768: {
                    slidesPerView: 1,
                },
                1024: {
                    slidesPerView: 1,
                }
            }
        });
    } catch (error) {
        console.error('Failed to initialize Swiper:', error);
        showToast('Failed to initialize interface', 'error');
    }
}

// ===== MODAL MANAGEMENT =====

/**
 * Show modal with content
 */
function showModal(content) {
    hideModal();
    
    const modalContainer = document.getElementById('modal-container');
    const modalWrapper = document.createElement('div');
    modalWrapper.id = 'active-modal';
    modalWrapper.dataset.action = "hide-modal";
    modalWrapper.className = 'fixed inset-0 z-30 overflow-y-auto modal-backdrop bg-black bg-opacity-50 flex items-center justify-center p-4';
    modalWrapper.innerHTML = `<div class="w-full max-w-sm pointer-events-none">${content}</div>`;
    
    modalContainer.appendChild(modalWrapper);
    
    // Animate in
    requestAnimationFrame(() => {
        modalWrapper.style.opacity = '1';
        const panel = modalWrapper.querySelector('.modal-panel');
        if (panel) {
            panel.classList.add('show');
        }
    });
}

/**
 * Hide active modal
 */
function hideModal() {
    const modalWrapper = document.getElementById('active-modal');
    if (modalWrapper) {
        modalWrapper.style.opacity = '0';
        const panel = modalWrapper.querySelector('.modal-panel');
        if (panel) {
            panel.classList.remove('show');
        }
        setTimeout(() => modalWrapper.remove(), 300);
    }
}

/**
 * Show sign in modal
 */
function showSignInModal() {
    const content = `
        <div class="modal-panel bg-white dark:bg-gray-800 rounded-2xl shadow-xl p-6 pointer-events-auto">
            <h2 class="text-2xl font-bold text-gray-800 dark:text-white mb-4 text-center">Welcome Back</h2>
            <form data-action="signin-submit">
                <input 
                    id="signin-email" 
                    type="email" 
                    placeholder="Email" 
                    required 
                    class="form-input w-full mb-4 px-4 py-2 rounded-lg bg-gray-100 dark:bg-gray-700 border border-gray-300 dark:border-gray-600 focus:border-orange-500 focus:outline-none"
                    aria-label="Email address">
                <input 
                    id="signin-password" 
                    type="password" 
                    placeholder="Password" 
                    required 
                    class="form-input w-full mb-4 px-4 py-2 rounded-lg bg-gray-100 dark:bg-gray-700 border border-gray-300 dark:border-gray-600 focus:border-orange-500 focus:outline-none"
                    aria-label="Password">
                <p id="signin-error" class="form-error mb-2" role="alert"></p>
                <button 
                    type="submit" 
                    class="btn-primary w-full py-2 rounded-lg text-white font-semibold border-b-4 border-orange-700 active:border-b-0">
                    Sign In
                </button>
            </form>
        </div>
    `;
    showModal(content);
    
    // Focus first input
    setTimeout(() => {
        const emailInput = document.getElementById('signin-email');
        if (emailInput) emailInput.focus();
    }, 100);
}

/**
 * Show registration modal
 */
function showRegisterModal() {
    const content = `
        <div class="modal-panel bg-white dark:bg-gray-800 rounded-2xl shadow-xl p-6 pointer-events-auto">
            <h2 class="text-2xl font-bold text-gray-800 dark:text-white mb-4 text-center">Join Pantry Pal</h2>
            <form data-action="register-submit">
                <input 
                    id="reg-firstname" 
                    type="text" 
                    placeholder="First Name" 
                    required 
                    class="form-input w-full mb-4 px-4 py-2 rounded-lg bg-gray-100 dark:bg-gray-700 border border-gray-300 dark:border-gray-600 focus:border-orange-500 focus:outline-none"
                    aria-label="First name">
                <input 
                    id="reg-email" 
                    type="email" 
                    placeholder="Email" 
                    required 
                    class="form-input w-full mb-4 px-4 py-2 rounded-lg bg-gray-100 dark:bg-gray-700 border border-gray-300 dark:border-gray-600 focus:border-orange-500 focus:outline-none"
                    aria-label="Email address">
                <input 
                    id="reg-password" 
                    type="password" 
                    placeholder="Password" 
                    required 
                    class="form-input w-full mb-2 px-4 py-2 rounded-lg bg-gray-100 dark:bg-gray-700 border border-gray-300 dark:border-gray-600 focus:border-orange-500 focus:outline-none"
                    aria-label="Password">
                <p id="password-strength" class="form-error" role="alert"></p>
                <p id="register-error" class="form-error mb-2" role="alert"></p>
                <button 
                    id="register-submit-button" 
                    type="submit" 
                    class="btn-primary w-full mt-2 py-2 rounded-lg text-white font-semibold disabled:bg-gray-400 border-b-4 border-orange-700 active:border-b-0 disabled:border-b-0" 
                    disabled>
                    Create Account
                </button>
            </form>
        </div>
    `;
    showModal(content);
    
    // Focus first input
    setTimeout(() => {
        const firstNameInput = document.getElementById('reg-firstname');
        if (firstNameInput) firstNameInput.focus();
    }, 100);
}

/**
 * Show item details modal
 */
function showDetailsModal(item) {
    const { status, message } = getExpirationInfo(item);
    const statusColor = status === 'expired' ? 'text-red-500' : 
                       status === 'expiring' ? 'text-yellow-500' : 'text-green-500';
    
    const content = `
        <div class="modal-panel bg-white dark:bg-gray-800 rounded-2xl shadow-xl p-6 pointer-events-auto">
            <div class="text-center mb-4">
                <div class="mx-auto w-16 h-16 mb-4 flex items-center justify-center">
                    ${foodIcons[item.icon] || foodIcons['default']}
                </div>
                <h2 class="text-2xl font-bold text-gray-800 dark:text-white">${item.name}</h2>
                <p class="text-gray-600 dark:text-gray-400">${item.category || 'Uncategorized'}</p>
            </div>
            
            <div class="space-y-3 mb-6">
                <div class="flex justify-between">
                    <span class="text-gray-600 dark:text-gray-400">Status:</span>
                    <span class="${statusColor} font-semibold">${message}</span>
                </div>
                ${item.expirationDate ? `
                <div class="flex justify-between">
                    <span class="text-gray-600 dark:text-gray-400">Expires:</span>
                    <span class="text-gray-800 dark:text-white">${new Date(item.expirationDate).toLocaleDateString()}</span>
                </div>
                ` : ''}
                <div class="flex justify-between">
                    <span class="text-gray-600 dark:text-gray-400">Added:</span>
                    <span class="text-gray-800 dark:text-white">${new Date(item.dateAdded).toLocaleDateString()}</span>
                </div>
            </div>
            
            <div class="flex space-x-3">
                <button 
                    data-action="delete-item" 
                    data-item-id="${item.id}"
                    class="flex-1 bg-red-500 hover:bg-red-600 text-white font-semibold py-2 px-4 rounded-lg transition-colors">
                    Remove
                </button>
                <button 
                    data-action="hide-modal"
                    class="flex-1 bg-gray-500 hover:bg-gray-600 text-white font-semibold py-2 px-4 rounded-lg transition-colors">
                    Close
                </button>
            </div>
        </div>
    `;
    showModal(content);
}

/**
 * Show add item modal
 */
function showAddModal() {
    const content = `
        <div class="modal-panel bg-white dark:bg-gray-800 rounded-2xl shadow-xl p-6 pointer-events-auto">
            <h2 class="text-2xl font-bold text-gray-800 dark:text-white mb-4 text-center">Add New Item</h2>
            <form data-action="add-item-submit">
                <input 
                    id="add-item-name" 
                    type="text" 
                    placeholder="Item name (e.g., Fresh Apples)" 
                    required 
                    class="form-input w-full mb-4 px-4 py-2 rounded-lg bg-gray-100 dark:bg-gray-700 border border-gray-300 dark:border-gray-600 focus:border-orange-500 focus:outline-none"
                    aria-label="Item name">
                
                <input 
                    id="add-item-expiration" 
                    type="date" 
                    class="form-input w-full mb-4 px-4 py-2 rounded-lg bg-gray-100 dark:bg-gray-700 border border-gray-300 dark:border-gray-600 focus:border-orange-500 focus:outline-none"
                    aria-label="Expiration date">
                
                <div class="mb-4">
                    <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Choose Icon:</label>
                    <div class="grid grid-cols-4 gap-2" id="icon-selector">
                        ${iconCategories.map(icon => `
                            <button 
                                type="button" 
                                data-icon="${icon}" 
                                class="icon-option p-2 rounded-lg border-2 border-gray-300 hover:border-orange-500 transition-colors ${icon === 'default' ? 'border-orange-500 bg-orange-50' : ''}"
                                aria-label="Select ${icon} icon">
                                ${foodIcons[icon]}
                            </button>
                        `).join('')}
                    </div>
                </div>
                
                <p id="add-item-error" class="form-error mb-2" role="alert"></p>
                <div class="flex space-x-3">
                    <button 
                        type="button" 
                        data-action="hide-modal"
                        class="flex-1 bg-gray-500 hover:bg-gray-600 text-white font-semibold py-2 px-4 rounded-lg transition-colors">
                        Cancel
                    </button>
                    <button 
                        type="submit" 
                        class="btn-primary flex-1 py-2 rounded-lg text-white font-semibold border-b-4 border-orange-700 active:border-b-0">
                        <span class="add-item-text">Add Item</span>
                        <div class="loader hidden"></div>
                    </button>
                </div>
            </form>
        </div>
    `;
    showModal(content);
    
    // Set up icon selection
    setupIconSelector();
    
    // Focus first input
    setTimeout(() => {
        const nameInput = document.getElementById('add-item-name');
        if (nameInput) nameInput.focus();
    }, 100);
}

/**
 * Set up icon selector functionality
 */
function setupIconSelector() {
    const iconOptions = document.querySelectorAll('.icon-option');
    let selectedIcon = 'default';
    
    iconOptions.forEach(option => {
        option.addEventListener('click', () => {
            // Remove selection from all options
            iconOptions.forEach(opt => {
                opt.classList.remove('border-orange-500', 'bg-orange-50');
                opt.classList.add('border-gray-300');
            });
            
            // Add selection to clicked option
            option.classList.remove('border-gray-300');
            option.classList.add('border-orange-500', 'bg-orange-50');
            selectedIcon = option.dataset.icon;
        });
    });
    
    // Store selected icon for form submission
    window.selectedIcon = selectedIcon;
}

/**
 * Show recipe modal
 */
function showRecipeModal() {
    const content = `
        <div class="modal-panel bg-white dark:bg-gray-800 rounded-2xl shadow-xl p-6 pointer-events-auto max-w-md">
            <h2 class="text-2xl font-bold text-gray-800 dark:text-white mb-4 text-center">Recipe Suggestions</h2>
            <form data-action="recipe-mood-submit">
                <div class="mb-4">
                    <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">What are you in the mood for?</label>
                    <select 
                        id="recipe-mood" 
                        class="form-input w-full px-4 py-2 rounded-lg bg-gray-100 dark:bg-gray-700 border border-gray-300 dark:border-gray-600 focus:border-orange-500 focus:outline-none"
                        aria-label="Recipe mood">
                        <option value="any">Surprise me!</option>
                        <option value="healthy">Something healthy</option>
                        <option value="comfort">Comfort food</option>
                        <option value="quick">Quick & easy</option>
                        <option value="fancy">Something fancy</option>
                    </select>
                </div>
                
                <div class="flex space-x-3">
                    <button 
                        type="button" 
                        data-action="hide-modal"
                        class="flex-1 bg-gray-500 hover:bg-gray-600 text-white font-semibold py-2 px-4 rounded-lg transition-colors">
                        Cancel
                    </button>
                    <button 
                        type="submit" 
                        class="btn-primary flex-1 py-2 rounded-lg text-white font-semibold border-b-4 border-orange-700 active:border-b-0">
                        <span class="recipe-text">Get Recipes</span>
                        <div class="loader hidden"></div>
                    </button>
                </div>
            </form>
            
            <div id="recipe-results" class="mt-6 hidden">
                <h3 class="text-lg font-semibold text-gray-800 dark:text-white mb-3">Your Recipes:</h3>
                <div id="recipe-list" class="space-y-4 max-h-64 overflow-y-auto"></div>
            </div>
        </div>
    `;
    showModal(content);
}

// ===== EVENT HANDLERS =====

/**
 * Handle user registration
 */
function handleRegister(e) {
    e.preventDefault();
    
    const email = document.getElementById('reg-email').value.trim();
    const password = document.getElementById('reg-password').value;
    const firstName = document.getElementById('reg-firstname').value.trim();
    const errorElement = document.getElementById('register-error');
    
    // Clear previous errors
    errorElement.textContent = '';
    
    // Validate inputs
    if (!firstName) {
        errorElement.textContent = 'First name is required';
        return;
    }
    
    if (!isValidEmail(email)) {
        errorElement.textContent = 'Please enter a valid email address';
        return;
    }
    
    const passwordValidation = validatePassword(password);
    if (!passwordValidation.isValid) {
        errorElement.textContent = passwordValidation.message;
        return;
    }
    
    // Check if user already exists
    if (userDatabase[email]) {
        errorElement.textContent = 'An account with this email already exists';
        return;
    }
    
    // Create new user
    userDatabase[email] = {
        password,
        firstName,
        foodItems: [],
        dateCreated: new Date().toISOString()
    };
    
    currentUserEmail = email;
    saveToStorage();
    
    showToast(`Welcome to Pantry Pal, ${firstName}!`, 'success');
    navigateToApp();
}

/**
 * Handle user sign in
 */
function handleSignIn(e) {
    e.preventDefault();
    
    const email = document.getElementById('signin-email').value.trim();
    const password = document.getElementById('signin-password').value;
    const errorElement = document.getElementById('signin-error');
    
    // Clear previous errors
    errorElement.textContent = '';
    
    // Validate inputs
    if (!isValidEmail(email)) {
        errorElement.textContent = 'Please enter a valid email address';
        return;
    }
    
    if (!password) {
        errorElement.textContent = 'Password is required';
        return;
    }
    
    // Check credentials
    const user = userDatabase[email];
    if (!user || user.password !== password) {
        errorElement.textContent = 'Invalid email or password';
        return;
    }
    
    currentUserEmail = email;
    saveToStorage();
    
    showToast(`Welcome back, ${user.firstName}!`, 'success');
    navigateToApp();
}

/**
 * Handle user sign out
 */
function handleSignOut() {
    currentUserEmail = null;
    saveToStorage();
    showToast('You have been signed out', 'info');
    navigateToApp();
}

/**
 * Handle adding new item
 */
async function handleAddItem(e) {
    e.preventDefault();
    
    const nameInput = document.getElementById('add-item-name');
    const expirationInput = document.getElementById('add-item-expiration');
    const errorElement = document.getElementById('add-item-error');
    const submitButton = e.target.querySelector('button[type="submit"]');
    const buttonText = submitButton.querySelector('.add-item-text');
    const loader = submitButton.querySelector('.loader');
    
    const itemName = nameInput.value.trim();
    const expirationDate = expirationInput.value;
    
    // Clear previous errors
    errorElement.textContent = '';
    
    // Validate input
    if (!itemName) {
        errorElement.textContent = 'Item name is required';
        return;
    }
    
    // Show loading state
    buttonText.classList.add('hidden');
    loader.classList.remove('hidden');
    submitButton.disabled = true;
    
    try {
        // Get AI-suggested icon and category
        const { icon, category } = await getIconAndCategory(itemName);
        
        // Create new item
        const newItem = {
            id: generateId(),
            name: itemName,
            icon: window.selectedIcon || icon,
            category,
            expirationDate: expirationDate || null,
            dateAdded: new Date().toISOString()
        };
        
        // Add to user's items
        if (!userDatabase[currentUserEmail].foodItems) {
            userDatabase[currentUserEmail].foodItems = [];
        }
        userDatabase[currentUserEmail].foodItems.push(newItem);
        
        saveToStorage();
        hideModal();
        renderFridge();
        
        showToast(`${itemName} added to your fridge!`, 'success');
        
    } catch (error) {
        console.error('Error adding item:', error);
        errorElement.textContent = 'Failed to add item. Please try again.';
    } finally {
        // Reset button state
        buttonText.classList.remove('hidden');
        loader.classList.add('hidden');
        submitButton.disabled = false;
    }
}

/**
 * Handle item deletion
 */
function handleDeleteItem(itemId) {
    if (!currentUserEmail || !userDatabase[currentUserEmail]) return;
    
    const items = userDatabase[currentUserEmail].foodItems;
    const itemIndex = items.findIndex(item => item.id === itemId);
    
    if (itemIndex !== -1) {
        const itemName = items[itemIndex].name;
        items.splice(itemIndex, 1);
        saveToStorage();
        hideModal();
        renderFridge();
        showToast(`${itemName} removed from your fridge`, 'info');
    }
}

/**
 * Handle recipe generation
 */
async function handleGenerateRecipes(e) {
    e.preventDefault();
    
    const moodSelect = document.getElementById('recipe-mood');
    const submitButton = e.target.querySelector('button[type="submit"]');
    const buttonText = submitButton.querySelector('.recipe-text');
    const loader = submitButton.querySelector('.loader');
    const resultsDiv = document.getElementById('recipe-results');
    const recipeList = document.getElementById('recipe-list');
    
    const mood = moodSelect.value;
    
    // Show loading state
    buttonText.classList.add('hidden');
    loader.classList.remove('hidden');
    submitButton.disabled = true;
    
    try {
        const result = await getRecipes(mood);
        
        // Display recipes
        recipeList.innerHTML = result.recipes.map(recipe => `
            <div class="bg-gray-50 dark:bg-gray-700 rounded-lg p-4">
                <h4 class="font-semibold text-gray-800 dark:text-white mb-2">${recipe.title}</h4>
                <p class="text-sm text-gray-600 dark:text-gray-300 mb-3">${recipe.description}</p>
                <div class="mb-3">
                    <h5 class="text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Ingredients:</h5>
                    <ul class="text-sm text-gray-600 dark:text-gray-400 list-disc list-inside">
                        ${recipe.ingredients.map(ingredient => `<li>${ingredient}</li>`).join('')}
                    </ul>
                </div>
                <div>
                    <h5 class="text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Instructions:</h5>
                    <ol class="text-sm text-gray-600 dark:text-gray-400 list-decimal list-inside">
                        ${recipe.instructions.map(instruction => `<li>${instruction}</li>`).join('')}
                    </ol>
                </div>
            </div>
        `).join('');
        
        resultsDiv.classList.remove('hidden');
        
    } catch (error) {
        console.error('Error generating recipes:', error);
        showToast('Failed to generate recipes. Please try again.', 'error');
    } finally {
        // Reset button state
        buttonText.classList.remove('hidden');
        loader.classList.add('hidden');
        submitButton.disabled = false;
    }
}

// ===== NAVIGATION =====

/**
 * Navigate between auth and main app screens
 */
function navigateToApp() {
    const isLoggedIn = currentUserEmail !== null;
    const authScreen = document.getElementById('auth-screen');
    const mainAppScreen = document.getElementById('main-app-screen');
    const fridgeContentArea = document.getElementById('fridge-content-area');
    
    if (isLoggedIn) {
        const user = userDatabase[currentUserEmail];
        document.getElementById('fridge-title').textContent = `${user.firstName}'s Fridge`;
        
        // Show loading state
        authScreen.style.display = 'none';
        mainAppScreen.style.display = 'flex';
        fridgeContentArea.innerHTML = `
            <div class="flex items-center justify-center h-full">
                <div class="text-center">
                    <div class="big-loader mb-4"></div>
                    <p class="text-cyan-900 font-semibold">Loading your fridge...</p>
                </div>
            </div>
        `;
        
        // Render fridge after short delay for smooth transition
        setTimeout(renderFridge, 500);
    } else {
        authScreen.style.display = 'flex';
        mainAppScreen.style.display = 'none';
    }
    
    hideModal();
}

// ===== EVENT DELEGATION SYSTEM =====

/**
 * Main event delegation handler
 */
function setupEventHandlers() {
    // Click event delegation
    document.body.addEventListener('click', function(e) {
        const target = e.target.closest('[data-action]');
        if (!target) return;
        
        const action = target.dataset.action;
        
        switch(action) {
            case 'show-signin':
                showSignInModal();
                break;
            case 'show-register':
                showRegisterModal();
                break;
            case 'get-recipes':
                showRecipeModal();
                break;
            case 'sign-out':
                handleSignOut();
                break;
            case 'add':
                showAddModal();
                break;
            case 'details':
                const foodItems = userDatabase[currentUserEmail]?.foodItems || [];
                const item = foodItems.find(i => i.id == target.dataset.itemId);
                if (item) showDetailsModal(item);
                break;
            case 'delete-item':
                if (confirm('Are you sure you want to remove this item?')) {
                    handleDeleteItem(target.dataset.itemId);
                }
                break;
            case 'hide-modal':
                hideModal();
                break;
        }
    });
    
    // Form submission event delegation
    document.body.addEventListener('submit', function(e) {
        e.preventDefault();
        const form = e.target.closest('form');
        if (!form) return;
        
        const action = form.dataset.action;
        
        switch(action) {
            case 'signin-submit':
                handleSignIn(e);
                break;
            case 'register-submit':
                handleRegister(e);
                break;
            case 'add-item-submit':
                handleAddItem(e);
                break;
            case 'recipe-mood-submit':
                handleGenerateRecipes(e);
                break;
        }
    });
    
    // Input event delegation for real-time validation
    document.body.addEventListener('input', function(e) {
        if (e.target.id === 'reg-password') {
            const passwordInput = e.target;
            const form = passwordInput.closest('form');
            if (!form) return;
            
            const strengthText = form.querySelector('#password-strength');
            const submitButton = form.querySelector('#register-submit-button');
            
            const validation = validatePassword(passwordInput.value);
            strengthText.textContent = validation.message;
            submitButton.disabled = !validation.isValid;
        }
        
        if (e.target.id === 'signin-email' || e.target.id === 'reg-email') {
            // Clear error when user starts typing
            const form = e.target.closest('form');
            const errorElement = form.querySelector('.form-error');
            if (errorElement && errorElement.textContent) {
                errorElement.textContent = '';
            }
        }
    });
    
    // Keyboard event delegation
    document.body.addEventListener('keydown', function(e) {
        // Close modal on Escape key
        if (e.key === 'Escape') {
            hideModal();
        }
        
        // Handle Enter key on ice cubes
        if (e.key === 'Enter' && e.target.classList.contains('ice-cube')) {
            e.target.click();
        }
    });
}

// ===== INITIALIZATION =====

/**
 * Initialize the application
 */
function initializeApp() {
    try {
        // Load saved data
        loadFromStorage();
        
        // Set up event handlers
        setupEventHandlers();
        
        // Navigate to appropriate screen
        navigateToApp();
        
        console.log('Pantry Pal initialized successfully');
    } catch (error) {
        console.error('Failed to initialize Pantry Pal:', error);
        showToast('Failed to initialize application', 'error');
    }
}

// ===== APPLICATION STARTUP =====

// Initialize when DOM is ready
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initializeApp);
} else {
    initializeApp();
}

// Handle page visibility changes
document.addEventListener('visibilitychange', function() {
    if (!document.hidden && currentUserEmail) {
        // Refresh fridge when page becomes visible
        renderFridge();
    }
});

// Handle window beforeunload for data persistence
window.addEventListener('beforeunload', function() {
    saveToStorage();
});

// Export functions for testing (if in a module environment)
if (typeof module !== 'undefined' && module.exports) {
    module.exports = {
        validatePassword,
        isValidEmail,
        getExpirationInfo,
        generateId
    };
}
