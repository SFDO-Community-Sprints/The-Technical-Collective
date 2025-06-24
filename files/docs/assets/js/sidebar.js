document.addEventListener('DOMContentLoaded', function() {
  var header = document.querySelector('.md-header__inner');
  var nav = document.querySelector('.md-sidebar--primary');
  var main = document.querySelector('.md-main');
  var container = document.querySelector('.md-container');

  if (header && nav && main && container) {
    var toggle = document.createElement('button');
    toggle.classList.add('md-sidebar-toggle');
    toggle.innerHTML = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M3 6h18v2H3V6m0 5h18v2H3v-2m0 5h18v2H3v-2z"/></svg>';
    header.insertBefore(toggle, header.firstChild);

    toggle.addEventListener('click', function() {
      container.classList.toggle('sidebar-hidden');
    });
  }

  // Carousel functionality
  var carousel = document.querySelector('.sprint-carousel');
  if (carousel) {
    var track = carousel.querySelector('.carousel-track');
    var slides = carousel.querySelectorAll('.carousel-slide');
    var dots = carousel.querySelectorAll('.carousel-dot');
    var prevBtn = carousel.querySelector('.carousel-prev');
    var nextBtn = carousel.querySelector('.carousel-next');
    
    var currentSlide = 0;
    var slideCount = slides.length;
    var autoPlayInterval;
    var autoPlayDelay = 5000; // 5 seconds

    // Initialize carousel
    function initCarousel() {
      if (slideCount <= 1) {
        // Hide navigation if only one slide
        prevBtn.style.display = 'none';
        nextBtn.style.display = 'none';
        carousel.querySelector('.carousel-dots').style.display = 'none';
        return;
      }
      
      updateSlide();
      startAutoPlay();
      
      // Add event listeners
      prevBtn.addEventListener('click', goToPrevSlide);
      nextBtn.addEventListener('click', goToNextSlide);
      
      // Add dot click listeners
      dots.forEach((dot, index) => {
        dot.addEventListener('click', () => goToSlide(index));
      });
      
      // Pause auto-play on hover
      carousel.addEventListener('mouseenter', pauseAutoPlay);
      carousel.addEventListener('mouseleave', startAutoPlay);
      
      // Keyboard navigation
      document.addEventListener('keydown', handleKeyboard);
    }

    // Update slide display
    function updateSlide() {
      slides.forEach((slide, index) => {
        slide.classList.toggle('active', index === currentSlide);
      });
      
      dots.forEach((dot, index) => {
        dot.classList.toggle('active', index === currentSlide);
      });
    }

    // Navigation functions
    function goToSlide(index) {
      currentSlide = index;
      updateSlide();
      resetAutoPlay();
    }

    function goToNextSlide() {
      currentSlide = (currentSlide + 1) % slideCount;
      updateSlide();
      resetAutoPlay();
    }

    function goToPrevSlide() {
      currentSlide = (currentSlide - 1 + slideCount) % slideCount;
      updateSlide();
      resetAutoPlay();
    }

    // Auto-play functions
    function startAutoPlay() {
      if (slideCount > 1) {
        autoPlayInterval = setInterval(goToNextSlide, autoPlayDelay);
      }
    }

    function pauseAutoPlay() {
      if (autoPlayInterval) {
        clearInterval(autoPlayInterval);
        autoPlayInterval = null;
      }
    }

    function resetAutoPlay() {
      pauseAutoPlay();
      startAutoPlay();
    }

    // Keyboard navigation
    function handleKeyboard(event) {
      if (!carousel.contains(document.activeElement)) return;
      
      switch(event.key) {
        case 'ArrowLeft':
          event.preventDefault();
          goToPrevSlide();
          break;
        case 'ArrowRight':
          event.preventDefault();
          goToNextSlide();
          break;
        case 'Home':
          event.preventDefault();
          goToSlide(0);
          break;
        case 'End':
          event.preventDefault();
          goToSlide(slideCount - 1);
          break;
      }
    }

    // Initialize the carousel
    initCarousel();
  }
});
