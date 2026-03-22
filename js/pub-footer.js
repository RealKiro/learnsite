/**
 * 现代化底部功能增强脚本
 * 包含返回顶部、平滑滚动等功能
 */

(function() {
    'use strict';

    // 返回顶部按钮功能
    function initBackToTop() {
        var backTopBtn = document.querySelector('.site-footer-backtop');
        if (!backTopBtn) return;

        // 监听滚动事件
        var scrollThreshold = 300;
        var isVisible = false;

        function updateBackTopVisibility() {
            var scrollTop = window.pageYOffset || document.documentElement.scrollTop;
            var shouldShow = scrollTop > scrollThreshold;

            if (shouldShow && !isVisible) {
                backTopBtn.classList.add('visible');
                isVisible = true;
            } else if (!shouldShow && isVisible) {
                backTopBtn.classList.remove('visible');
                isVisible = false;
            }
        }

        // 节流函数
        var throttleTimer = null;
        function throttle(func, delay) {
            return function() {
                if (throttleTimer) return;
                throttleTimer = setTimeout(function() {
                    func();
                    throttleTimer = null;
                }, delay);
            };
        }

        window.addEventListener('scroll', throttle(updateBackTopVisibility, 100));
        updateBackTopVisibility();

        // 点击返回顶部
        backTopBtn.addEventListener('click', function() {
            smoothScrollTo(0, 600);
        });
    }

    // 平滑滚动函数
    function smoothScrollTo(targetY, duration) {
        var startY = window.pageYOffset || document.documentElement.scrollTop;
        var distance = targetY - startY;
        var startTime = null;

        function animation(currentTime) {
            if (startTime === null) startTime = currentTime;
            var timeElapsed = currentTime - startTime;
            var progress = Math.min(timeElapsed / duration, 1);
            
            // 缓动函数 (easeInOutCubic)
            var ease = progress < 0.5
                ? 4 * progress * progress * progress
                : 1 - Math.pow(-2 * progress + 2, 3) / 2;

            window.scrollTo(0, startY + distance * ease);

            if (timeElapsed < duration) {
                requestAnimationFrame(animation);
            }
        }

        requestAnimationFrame(animation);
    }

    // 底部链接平滑滚动
    function initSmoothLinks() {
        var links = document.querySelectorAll('.site-footer a[href^="#"]');
        
        links.forEach(function(link) {
            link.addEventListener('click', function(e) {
                var href = this.getAttribute('href');
                if (href === '#' || href === '#top') {
                    e.preventDefault();
                    smoothScrollTo(0, 600);
                    return;
                }

                var target = document.querySelector(href);
                if (target) {
                    e.preventDefault();
                    var targetY = target.getBoundingClientRect().top + window.pageYOffset - 80;
                    smoothScrollTo(targetY, 600);
                }
            });
        });
    }

    // 底部动画效果
    function initFooterAnimation() {
        var footer = document.querySelector('.site-footer');
        if (!footer) return;

        var observer = new IntersectionObserver(function(entries) {
            entries.forEach(function(entry) {
                if (entry.isIntersecting) {
                    footer.style.opacity = '1';
                    footer.style.transform = 'translateY(0)';
                }
            });
        }, {
            threshold: 0.1
        });

        footer.style.opacity = '0';
        footer.style.transform = 'translateY(20px)';
        footer.style.transition = 'opacity 0.6s ease, transform 0.6s ease';
        
        observer.observe(footer);
    }

    // 当前年份自动更新
    function updateCopyrightYear() {
        var copyrightElements = document.querySelectorAll('.site-footer-copyright');
        var currentYear = new Date().getFullYear();
        
        copyrightElements.forEach(function(element) {
            var text = element.textContent || element.innerText;
            // 替换 {year} 占位符
            if (text.indexOf('{year}') !== -1) {
                element.textContent = text.replace('{year}', currentYear);
            }
        });
    }

    // 初始化所有功能
    function init() {
        // 等待 DOM 加载完成
        if (document.readyState === 'loading') {
            document.addEventListener('DOMContentLoaded', function() {
                initBackToTop();
                initSmoothLinks();
                initFooterAnimation();
                updateCopyrightYear();
            });
        } else {
            initBackToTop();
            initSmoothLinks();
            initFooterAnimation();
            updateCopyrightYear();
        }
    }

    init();
})();
