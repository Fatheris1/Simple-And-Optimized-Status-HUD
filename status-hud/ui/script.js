// Cache DOM elements
const hudElements = {
    hud: document.getElementById('status-hud'),
    health: {
        bar: document.querySelector('.health .bar-fill'),
        value: document.querySelector('.health .value')
    },
    armor: {
        bar: document.querySelector('.armor .bar-fill'),
        value: document.querySelector('.armor .value')
    },
    food: {
        bar: document.querySelector('.food .bar-fill'),
        value: document.querySelector('.food .value')
    },
    water: {
        bar: document.querySelector('.water .bar-fill'),
        value: document.querySelector('.water .value')
    },
    id: document.querySelector('.id-value'),
    location: document.querySelector('.location-value')
};

// Cache last values to avoid unnecessary DOM updates
const lastValues = {
    health: -1,
    armor: -1,
    food: -1,
    water: -1
};

let updatePending = false;
let pendingUpdates = {};

window.addEventListener('message', function(event) {
    if (event.data.type === 'updateStatusHud') {
        if (event.data.show) {
            document.getElementById('status-hud').style.display = 'block';
            
            // Update and show/hide player ID
            const idElement = document.getElementById('player-id');
            if (event.data.showId) {
                idElement.style.display = 'block';
                document.querySelector('.id-value').textContent = 'ID: ' + event.data.id;
            } else {
                idElement.style.display = 'none';
            }
            
            // Update and show/hide location
            const locationElement = document.getElementById('player-location');
            if (event.data.showLocation) {
                locationElement.style.display = 'block';
                document.querySelector('.location-value').textContent = event.data.location || 'Unknown Location';
            } else {
                locationElement.style.display = 'none';
            }
            
            // Update health bar
            updateBar('health', Math.floor(event.data.health));
            
            // Update armor bar
            updateBar('armor', Math.floor(event.data.armor));
            
            // Update food bar
            updateBar('food', Math.floor(event.data.food));
            
            // Update water bar
            updateBar('water', Math.floor(event.data.water));
        } else {
            document.getElementById('status-hud').style.display = 'none';
        }
    }
});

function updateHUD() {
    updatePending = false;

    // Update each status if changed
    Object.entries(pendingUpdates).forEach(([type, value]) => {
        if (value !== lastValues[type]) {
            const element = hudElements[type];
            if (element) {
                element.bar.style.width = `${value}%`;
                element.value.textContent = `${value}%`;
                lastValues[type] = value;
            }
        }
    });
}

function updateBar(type, value) {
    const bar = document.querySelector('.' + type + ' .bar-fill');
    const valueElement = document.querySelector('.' + type + ' .value');
    if (bar && valueElement) {
        // Ensure value is a whole number
        value = Math.floor(value);
        bar.style.width = value + '%';
        valueElement.textContent = value + '%';
    }
}
