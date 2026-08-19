document.addEventListener('DOMContentLoaded', function () {

    /* Pill: subtle shrink + glow on scroll */
    var onScroll = function () {
        document.body.classList.toggle('scrolled', (window.scrollY || window.pageYOffset) > 24);
    };
    onScroll();
    window.addEventListener('scroll', onScroll, { passive: true });

    /* Reveal on scroll */
    var reveals = document.querySelectorAll('.reveal');
    if ('IntersectionObserver' in window) {
        var io = new IntersectionObserver(function (entries) {
            entries.forEach(function (e) {
                if (e.isIntersecting) {
                    e.target.classList.add('in');
                    io.unobserve(e.target);
                }
            });
        }, { threshold: 0.12 });
        reveals.forEach(function (el) { io.observe(el); });
    } else {
        reveals.forEach(function (el) { el.classList.add('in'); });
    }

    /* Auto-scroll hero -> collections, una sola volta per sessione */
    if (document.body.dataset.page === 'home') {
        var locked = sessionStorage.getItem('miami-autoscroll');
        if (!locked) {
            var startAutoScroll = function () {
                setTimeout(function () {
                    var target = document.getElementById('collections');
                    if (target && target.getBoundingClientRect().top > 40) {
                        target.scrollIntoView({ behavior: 'smooth', block: 'start' });
                    }
                    sessionStorage.setItem('miami-autoscroll', '1');
                }, 1600);
            };
            if (document.fonts && document.fonts.ready) {
                document.fonts.ready.then(startAutoScroll);
            } else {
                startAutoScroll();
            }
        }
    }
});