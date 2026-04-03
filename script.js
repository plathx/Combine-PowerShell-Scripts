window.addEventListener('load', () => {
    setTimeout(() => {
        document.getElementById('page-loader').classList.add('hidden');
        setTimeout(() => {
            document.body.classList.add('loaded');
        }, 100);
    }, 600);
});

document.addEventListener('contextmenu', e => e.preventDefault());

document.addEventListener('selectstart', e => {
    if (e.target.tagName.toLowerCase() !== 'input') {
        e.preventDefault();
    }
});

document.addEventListener('dragstart', e => {
    e.preventDefault();
});

document.addEventListener('keydown', e => {
    if (e.key === 'F12' || e.keyCode === 123) {
        e.preventDefault();
        return false;
    }
    
    if (e.ctrlKey && e.shiftKey && (e.key === 'I' || e.key === 'i' || e.keyCode === 73)) {
        e.preventDefault();
        return false;
    }
    
    if (e.ctrlKey && e.shiftKey && (e.key === 'J' || e.key === 'j' || e.keyCode === 74)) {
        e.preventDefault();
        return false;
    }
    
    if (e.ctrlKey && e.shiftKey && (e.key === 'C' || e.key === 'c' || e.keyCode === 67)) {
        e.preventDefault();
        return false;
    }
    
    if (e.ctrlKey && (e.key === 'U' || e.key === 'u' || e.keyCode === 85)) {
        e.preventDefault();
        return false;
    }
    
    if (e.ctrlKey && ['c', 'C', 'x', 'X', 'a', 'A', 'v', 'V'].includes(e.key)) {
        if (e.target.tagName.toLowerCase() !== 'input') {
            e.preventDefault();
            return false;
        }
    }
});

const scriptData = [
    { id: 10, name: "ปรับแต่ง Windows (WinUtil)", cmd: "irm http://raw.githubusercontent.com/phwyverysad/-/refs/heads/main/powershell/winutil.ps1 | iex", category: "System", icon: "ph-wrench" },
    { id: 3, name: "PowerPlan (KernelOS)", cmd: "irm http://raw.githubusercontent.com/phwyverysad/-/refs/heads/main/powershell/Install_powerplan.ps1 | iex", category: "System", icon: "ph-lightning" },
    { id: 9, name: "Clean Ram", cmd: "irm https://raw.githubusercontent.com/phwyverysad/-/refs/heads/main/powershell/clean_ram.ps1 | iex", category: "System", icon: "ph-broom" },
    { id: 1, name: "ล็อกไมค์ (Lock Mic)", cmd: "irm http://raw.githubusercontent.com/phwyverysad/-/refs/heads/main/powershell/lock_mic.ps1 | iex", category: "System", icon: "ph-microphone-slash" },
    { id: 12, name: "สร้างจุดย้อนระบบ (Restore)", cmd: "irm http://raw.githubusercontent.com/phwyverysad/-/refs/heads/main/powershell/system_restore.ps1 | iex", category: "System", icon: "ph-clock-counter-clockwise" },
    { id: 13, name: "เมนูทางลัด Power/BIOS", cmd: "irm http://raw.githubusercontent.com/phwyverysad/-/refs/heads/main/powershell/menu_options.ps1 | iex", category: "System", icon: "ph-power" },
    { id: 5, name: "โหลด OS ทับ (Atlas/ReviOS)", cmd: "irm http://raw.githubusercontent.com/phwyverysad/-/refs/heads/main/powershell/playbook_downloader.ps1 | iex", category: "OS", icon: "ph-hard-drive" },
    { id: 21, name: "เปิดใช้งาน Windows (แท้)", cmd: "irm http://raw.githubusercontent.com/phwyverysad/-/refs/heads/main/powershell/activate_windowsall.ps1 | iex", category: "OS", icon: "ph-key" },
    { id: 22, name: "เปลี่ยนรุ่น Windows", cmd: "irm http://raw.githubusercontent.com/phwyverysad/-/refs/heads/main/powershell/change_windows_edition.ps1 | iex", category: "OS", icon: "ph-swap" },
    { id: 23, name: "เช็คสถานะ Activate", cmd: "irm http://raw.githubusercontent.com/phwyverysad/-/refs/heads/main/powershell/check_status_windows.ps1 | iex", category: "OS", icon: "ph-info" },
    { id: 29, name: "ลงวินโดวส์ใหม่", cmd: "irm https://raw.githubusercontent.com/phwyverysad/-/refs/heads/main/powershell/windows1011 | iex", category: "OS", icon: "ph-disc" },
    { id: 20, name: "เปิดใช้งาน Microsoft 365", cmd: "irm http://raw.githubusercontent.com/phwyverysad/-/refs/heads/main/powershell/activate_365.ps1 | iex", category: "OS", icon: "ph-briefcase" },
    { id: 16, name: "จัดการไดรเวอร์ (IObit)", cmd: "irm http://raw.githubusercontent.com/phwyverysad/-/refs/heads/main/powershell/IObit_Driver_Booster_Pro.ps1 | iex", category: "Apps", icon: "ph-cpu" },
    { id: 15, name: "Revo Uninstaller Pro", cmd: "irm http://raw.githubusercontent.com/phwyverysad/-/refs/heads/main/powershell/revo_uninstaller_pro.ps1 | iex", category: "Apps", icon: "ph-trash" },
    { id: 19, name: "IDM (โหลดไว)", cmd: "irm http://raw.githubusercontent.com/phwyverysad/-/refs/heads/main/powershell/idm_build.ps1 | iex", category: "Apps", icon: "ph-download-simple" },
    { id: 8, name: "Discord 3 ตัว", cmd: "irm http://raw.githubusercontent.com/phwyverysad/-/refs/heads/main/powershell/discord.ps1 | iex", category: "Apps", icon: "ph-discord-logo" },
    { id: 26, name: "Web Browser", cmd: "irm https://raw.githubusercontent.com/phwyverysad/-/refs/heads/main/powershell/browser.ps1 | iex", category: "Apps", icon: "ph-globe-hemisphere-west" },
    { id: 27, name: "X-Mouse Button Control", cmd: "irm https://raw.githubusercontent.com/phwyverysad/-/refs/heads/main/powershell/X-Mouse_Button_Control.ps1 | iex", category: "Apps", icon: "ph-mouse" },
    { id: 28, name: "Partition Wizard Pro", cmd: "irm https://raw.githubusercontent.com/phwyverysad/-/refs/heads/main/powershell/MiniTool_Partition_Wizard_Pro.ps1 | iex", category: "Apps", icon: "ph-hard-drives" },
    { id: 11, name: "ฝากไฟล์ & แชร์ไฟล์", cmd: "irm http://raw.githubusercontent.com/phwyverysad/-/refs/heads/main/powershell/Upload_Share_Files.ps1 | iex", category: "Apps", icon: "ph-cloud-arrow-up" },
    { id: 18, name: "ย่อลิ้งก์ให้สั้น (Short Link)", cmd: "irm http://raw.githubusercontent.com/phwyverysad/-/refs/heads/main/powershell/cut_link.ps1 | iex", category: "Apps", icon: "ph-link" },
    { id: 17, name: "ติดตั้งส่วนเสริม (Dev Tools)", cmd: "irm http://raw.githubusercontent.com/phwyverysad/-/refs/heads/main/powershell/dev_tools.ps1 | iex", category: "Apps", icon: "ph-puzzle-piece" },
    { id: 31, name: "YouTube Adblock", cmd: "irm https://raw.githubusercontent.com/phwyverysad/-/refs/heads/main/powershell/YouTube.ps1 | iex", category: "Apps", icon: "ph-youtube-logo" },
    { id: 6, name: "แปลงไฟล์ .py เป็น .exe", cmd: "irm http://raw.githubusercontent.com/phwyverysad/-/refs/heads/main/powershell/py_to_exe.ps1 | iex", category: "Apps", icon: "ph-file-code" },
    { id: 2, name: "เสกเกม (Steam)", cmd: "irm https://raw.githubusercontent.com/phwyverysad/-/refs/heads/main/powershell/import_games_steam.ps1 | iex", category: "Gaming", icon: "ph-game-controller" },
    { id: 14, name: "Lossless Scaling", cmd: "irm http://raw.githubusercontent.com/phwyverysad/-/refs/heads/main/powershell/lossless_scaling.ps1 | iex", category: "Gaming", icon: "ph-arrows-out-simple" },
    { id: 7, name: "Minecraft for Windows", cmd: "irm http://raw.githubusercontent.com/phwyverysad/-/refs/heads/main/powershell/minecraft_for_windows.ps1 | iex", category: "Gaming", icon: "ph-cube" },
    { id: 4, name: "Spotify Premium", cmd: "irm https://raw.githubusercontent.com/phwyverysad/-/refs/heads/main/powershell/spotify_premium.ps1 | iex", category: "Gaming", icon: "ph-spotify-logo" },
    { id: 30, name: "Remove Windows Defender", cmd: "irm https://gist.github.com/phwyverysad/719da2821717ab9b6ec83e1cca2a0298/raw/e88ce7ded6eeb52a488ff5632a5e9e9dee73da68/RemoveWindowsDefender.ps1 | iex", category: "Security", icon: "ph-shield-slash" },
    { id: 24, name: "Avast Premium", cmd: "irm http://raw.githubusercontent.com/phwyverysad/-/refs/heads/main/powershell/avast_premium_security.ps1 | iex", category: "Security", icon: "ph-shield-check" },
    { id: 25, name: "Malwarebytes Premium", cmd: "irm http://raw.githubusercontent.com/phwyverysad/-/refs/heads/main/powershell/malwarebytes_premium.ps1 | iex", category: "Security", icon: "ph-bug-beetle" }
];

const categories = [
    { id: "All", name: "หน้าแรก (ทั้งหมด)", icon: "ph-squares-four" },
    { id: "System", name: "ปรับแต่งระบบ", icon: "ph-sliders-horizontal" },
    { id: "OS", name: "จัดการ Windows", icon: "ph-windows-logo" },
    { id: "Apps", name: "แอป & เครื่องมือ", icon: "ph-app-window" },
    { id: "Gaming", name: "เกม & สื่อบันเทิง", icon: "ph-game-controller" },
    { id: "Security", name: "ความปลอดภัย", icon: "ph-shield" }
];

let currentCategory = "All";
let searchTerm = "";

const themeToggle = document.getElementById('theme-toggle');
themeToggle.addEventListener('click', () => {
    themeToggle.classList.add('spin-anim');
    setTimeout(() => themeToggle.classList.remove('spin-anim'), 400);

    document.body.classList.toggle('dark');
    const icon = themeToggle.querySelector('i');
    
    setTimeout(() => {
        if (document.body.classList.contains('dark')) {
            icon.className = 'ph-bold ph-sun';
            localStorage.setItem('theme', 'dark');
        } else {
            icon.className = 'ph-bold ph-moon';
            localStorage.setItem('theme', 'light');
        }
    }, 100);
});

const savedTheme = localStorage.getItem('theme');
if (savedTheme === 'dark') {
    document.body.classList.add('dark');
    themeToggle.querySelector('i').className = 'ph-bold ph-sun';
}

const cursorGlow = document.getElementById('cursor-glow');
let raf;
document.addEventListener('mousemove', (e) => {
    if(raf) cancelAnimationFrame(raf);
    raf = requestAnimationFrame(() => {
        cursorGlow.style.opacity = '1';
        cursorGlow.style.left = `${e.clientX}px`;
        cursorGlow.style.top = `${e.clientY}px`;
    });
});
document.addEventListener('mouseleave', () => cursorGlow.style.opacity = '0');

function renderMenu() {
    const menuList = document.getElementById('menu-list');
    let menuHtml = '<div class="menu-title">หมวดหมู่สคริปต์</div>';
    
    categories.forEach((cat) => {
        const isActive = currentCategory === cat.id ? 'active' : '';
        menuHtml += `
            <div class="menu-item ${isActive}" onclick="changeCategory('${cat.id}', '${cat.name}')">
                <i class="${isActive ? 'ph-fill' : 'ph'} ${cat.icon} ph-lg"></i>
                <span>${cat.name}</span>
            </div>`;
    });
    
    menuList.innerHTML = menuHtml;
}

function changeCategory(id, name) {
    if (currentCategory === id && searchTerm === "") return; 
    
    currentCategory = id; 
    searchTerm = ""; 
    document.getElementById('search-input').value = "";
    
    const titleEl = document.getElementById('category-title');
    titleEl.style.transform = 'translateY(-10px)'; 
    titleEl.style.opacity = '0';
    
    const grid = document.getElementById('card-grid');
    grid.classList.add('fade-out');
    
    setTimeout(() => {
        titleEl.innerText = name; 
        titleEl.style.transform = 'translateY(10px)';
        
        setTimeout(() => { 
            titleEl.style.transform = 'translateY(0)'; 
            titleEl.style.opacity = '1'; 
        }, 30);
        
        renderMenu(); 
        renderCards();
        grid.classList.remove('fade-out');
        const scroller = document.querySelector('.main-content') || document.getElementById('content-scroll');
        if(scroller) scroller.scrollTo({ top: 0, behavior: 'smooth' });
        
        if (window.innerWidth <= 900) {
            document.getElementById('sidebar')?.classList.remove('open');
            document.getElementById('mobile-overlay')?.classList.remove('show');
        }
    }, 150);
}

let searchTimeout;
document.getElementById('search-input').addEventListener('input', (e) => {
    clearTimeout(searchTimeout);
    searchTimeout = setTimeout(() => {
        searchTerm = e.target.value.toLowerCase(); 
        if(searchTerm !== "") {
            document.getElementById('category-title').innerText = `ผลการค้นหา: "${e.target.value}"`;
            currentCategory = "Search"; 
            renderMenu();
        } else {
            changeCategory("All", "หน้าแรก (ทั้งหมด)");
            return;
        }
        renderCards();
    }, 150);
});

function renderCards() {
    const grid = document.getElementById('card-grid'); 
    grid.innerHTML = '';
    
    let filteredData = searchTerm !== "" 
        ? scriptData.filter(i => i.name.toLowerCase().includes(searchTerm) || i.category.toLowerCase().includes(searchTerm))
        : currentCategory !== "All" ? scriptData.filter(i => i.category === currentCategory) : scriptData;
        
    document.getElementById('item-count').innerText = `พบ ${filteredData.length} รายการ`;
    
    if (filteredData.length === 0) {
        grid.innerHTML = `
            <div style="grid-column: 1/-1; text-align: center; padding: 60px 20px; color: var(--text-muted); opacity: 0; animation: fadeDown 0.3s forwards;">
                <i class="ph ph-ghost" style="font-size: 4rem; margin-bottom: 15px; display: block; opacity: 0.6;"></i>
                <p style="font-size: 1.1rem; font-weight: 500;">ไม่พบสคริปต์ที่คุณค้นหา 🦇</p>
            </div>`; 
        return;
    }
    
    filteredData.forEach((item, index) => {
        const card = document.createElement('div'); 
        card.className = 'card'; 
        card.style.animationDelay = `${(index * 0.05) + 0.5}s`;
        
        card.innerHTML = `
            <div class="card-header">
                <div class="card-icon"><i class="ph ${item.icon}"></i></div>
                <div class="card-title">${item.name}</div>
            </div>
            <div class="code-box" id="code-${item.id}">${item.cmd}</div>
            <button class="copy-btn" onclick="copyToClipboard('${item.cmd}', this, 'code-${item.id}')">
                <i class="ph ph-copy"></i> <span>คัดลอกคำสั่ง</span>
            </button>`;
            
        let hoverRaf;
        card.addEventListener('mousemove', e => {
            if(hoverRaf) cancelAnimationFrame(hoverRaf);
            hoverRaf = requestAnimationFrame(() => {
                const rect = card.getBoundingClientRect();
                const x = e.clientX - rect.left;
                const y = e.clientY - rect.top;
                
                card.style.setProperty('--mouse-x', `${x}px`);
                card.style.setProperty('--mouse-y', `${y}px`);
                
                const centerX = rect.width / 2;
                const centerY = rect.height / 2;
                const rotateX = ((y - centerY) / centerY) * -5;
                const rotateY = ((x - centerX) / centerX) * 5;
                
                card.style.setProperty('--rx', `${rotateX}deg`);
                card.style.setProperty('--ry', `${rotateY}deg`);
            });
        });

        card.addEventListener('mouseleave', () => {
            if(hoverRaf) cancelAnimationFrame(hoverRaf);
            card.style.setProperty('--rx', `0deg`);
            card.style.setProperty('--ry', `0deg`);
        });
            
        grid.appendChild(card);
    });
}

function copyToClipboard(text, btnElement, codeBoxId) {
    navigator.clipboard.writeText(text).then(() => {
        const codeBox = document.getElementById(codeBoxId); 
        const originalHtml = btnElement.innerHTML;
        
        codeBox.classList.remove('flash'); 
        void codeBox.offsetWidth; 
        codeBox.classList.add('flash');
        
        btnElement.innerHTML = `<i class="ph-bold ph-check"></i> <span>คัดลอกแล้ว</span>`;
        btnElement.style.background = 'var(--text-main)'; 
        btnElement.style.color = 'var(--bg-base)';
        
        const toast = document.getElementById('toast'); 
        toast.classList.add('show');
        
        setTimeout(() => {
            btnElement.innerHTML = originalHtml; 
            btnElement.style.background = ''; 
            btnElement.style.color = '';
            toast.classList.remove('show');
        }, 1500);
        
    }).catch(err => {
        alert("ระบบเบราว์เซอร์ของคุณไม่รองรับการคัดลอก");
    });
}

renderMenu(); 
renderCards();

// Mobile Menu Logic
const menuBtn = document.getElementById('menu-btn');
const sidebar = document.getElementById('sidebar');
const mobileOverlay = document.getElementById('mobile-overlay');

function toggleMobileMenu() {
    if(sidebar) sidebar.classList.toggle('open');
    if(mobileOverlay) mobileOverlay.classList.toggle('show');
}

if (menuBtn) {
    menuBtn.addEventListener('click', toggleMobileMenu);
}
if (mobileOverlay) {
    mobileOverlay.addEventListener('click', toggleMobileMenu);
}

// Sticky Header Scroll Effect
const mainContentScroller = document.querySelector('.main-content');
const mainHeader = document.getElementById('header');

if (mainContentScroller && mainHeader) {
    mainContentScroller.addEventListener('scroll', () => {
        if (mainContentScroller.scrollTop > 30) {
            mainHeader.classList.add('scrolled');
        } else {
            mainHeader.classList.remove('scrolled');
        }
    });
}
