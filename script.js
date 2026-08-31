/**
 * Wairimu Dream Defensive Driving School
 * Agency Standard JavaScript Engine
 */

document.addEventListener('DOMContentLoaded', () => {
  initNavigation();
  initFaqAccordion();
  initCopyrightYear();
  initContactFormHandler();
});

/* ==========================================================================
   1. Responsive Navigation & Sticky Header
   ========================================================================== */
function initNavigation() {
  const toggleBtn = document.getElementById('navToggleBtn') || document.getElementById('hamburgerBtn');
  const navMenu = document.getElementById('mainNavigation') || document.getElementById('navMenu');
  const navLinks = document.querySelectorAll('.nav-item-link, .nav-link');

  if (toggleBtn && navMenu) {
    toggleBtn.addEventListener('click', (e) => {
      e.stopPropagation();
      navMenu.classList.toggle('active');
    });

    document.addEventListener('click', (e) => {
      if (navMenu.classList.contains('active') && !navMenu.contains(e.target) && !toggleBtn.contains(e.target)) {
        navMenu.classList.remove('active');
      }
    });

    navLinks.forEach((link) => {
      link.addEventListener('click', () => {
        navMenu.classList.remove('active');
      });
    });
  }

  // Highlight active link based on current path
  const currentPath = window.location.pathname.split('/').pop() || 'index.html';
  navLinks.forEach((link) => {
    const href = link.getAttribute('href');
    link.classList.remove('active');
    if (href === currentPath || (currentPath === '' && href === 'index.html')) {
      link.classList.add('active');
    }
  });
}

/* ==========================================================================
   2. Interactive FAQ Accordion
   ========================================================================== */
function initFaqAccordion() {
  const faqButtons = document.querySelectorAll('.faq-question-btn');
  if (!faqButtons.length) return;

  faqButtons.forEach((btn) => {
    btn.addEventListener('click', () => {
      const item = btn.closest('.faq-item');
      const isActive = item.classList.contains('active');

      // Optional: close other open items for clean single accordion
      document.querySelectorAll('.faq-item').forEach((otherItem) => {
        otherItem.classList.remove('active');
        const otherBtn = otherItem.querySelector('.faq-question-btn');
        if (otherBtn) otherBtn.setAttribute('aria-expanded', 'false');
      });

      if (!isActive) {
        item.classList.add('active');
        btn.setAttribute('aria-expanded', 'true');
      } else {
        item.classList.remove('active');
        btn.setAttribute('aria-expanded', 'false');
      }
    });
  });
}

/* ==========================================================================
   3. Dynamic Copyright Year
   ========================================================================== */
function initCopyrightYear() {
  const yearSpan = document.getElementById('currentYear');
  if (yearSpan) {
    yearSpan.textContent = new Date().getFullYear();
  }
}

/* ==========================================================================
   4. Contact Form Handler & WhatsApp Link Generator
   ========================================================================== */
function initContactFormHandler() {
  const contactForm = document.getElementById('enrollmentForm') || document.getElementById('contactForm');
  if (!contactForm) return;

  contactForm.addEventListener('submit', (e) => {
    e.preventDefault();

    const fullName = document.getElementById('fullName')?.value || '';
    const phone = document.getElementById('phone')?.value || '';
    const email = document.getElementById('email')?.value || '';
    const branch = document.getElementById('branch')?.value || 'General Inquiry';
    const course = document.getElementById('courseCategory')?.value || 'General Inquiry';
    const message = document.getElementById('message')?.value || '';

    const waMessage = `Hello Wairimu Dream Driving School,%0A%0AI would like to enroll in driving classes:%0A- *Name:* ${encodeURIComponent(fullName)}%0A- *Phone:* ${encodeURIComponent(phone)}%0A- *Email:* ${encodeURIComponent(email)}%0A- *Branch:* ${encodeURIComponent(branch)}%0A- *Course:* ${encodeURIComponent(course)}${message ? `%0A- *Notes:* ${encodeURIComponent(message)}` : ''}`;

    const waUrl = `https://wa.me/254721807552?text=${waMessage}`;
    window.open(waUrl, '_blank');
  });
}
