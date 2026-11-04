/**
 * CPMS Form Validation & Custom Error Messages
 * Prevents native browser tooltips ("Please fill out this field")
 * and displays inline red error message below empty required fields:
 * "[Tên ô] không được để trống"
 */
(function () {
    'use strict';

    // 1. Permanently suppress native browser tooltip balloons
    document.addEventListener('invalid', function (e) {
        e.preventDefault();
        if (e.target) {
            showFieldError(e.target);
        }
    }, true);

    function cleanLabelText(lbl) {
        if (!lbl) return '';
        var clone = lbl.cloneNode(true);
        // Remove child form elements, buttons, links, icons, small help text
        var toRemove = clone.querySelectorAll('input, select, textarea, button, a, small, i, .help-text, span.badge');
        for (var i = 0; i < toRemove.length; i++) {
            toRemove[i].remove();
        }
        var text = clone.textContent || '';
        // Remove *, colons, dashes, and normalize whitespace
        text = text.replace(/[\*\:\—\-\–]/g, ' ').replace(/\s+/g, ' ').trim();
        return text;
    }

    function getFieldName(field) {
        if (!field) return 'Trường này';

        // Explicit data attribute
        if (field.getAttribute('data-field-name')) {
            return field.getAttribute('data-field-name').trim();
        }

        // 1. label[for="id"]
        if (field.id) {
            try {
                var lbl = document.querySelector('label[for="' + CSS.escape(field.id) + '"]');
                if (lbl) {
                    var t = cleanLabelText(lbl);
                    if (t) return t;
                }
            } catch (err) {}
        }

        // 2. Enclosing <label>
        var parentLabel = field.closest ? field.closest('label') : null;
        if (parentLabel) {
            var t2 = cleanLabelText(parentLabel);
            if (t2) return t2;
        }

        // 3. Label inside closest parent container (.form-group, .form-row, td, tr, etc.)
        var container = field.closest ? field.closest('.form-group, .form-row, td, tr, .field-wrapper') : null;
        if (!container && field.parentElement) {
            container = field.parentElement;
        }
        if (container) {
            var groupLabel = container.querySelector('label');
            if (groupLabel && groupLabel !== parentLabel) {
                var t3 = cleanLabelText(groupLabel);
                if (t3) return t3;
            }
            var th = container.querySelector('th');
            if (th) {
                var tTh = cleanLabelText(th);
                if (tTh) return tTh;
            }
        }

        // 4. Placeholder
        var placeholder = field.getAttribute('placeholder');
        if (placeholder && placeholder.trim()) {
            var cleanPh = placeholder.trim()
                .replace(/^(Nhập|Chọn|Điền)\s+/i, '')
                .replace(/^(ví dụ|e\.g\.?):.*$/i, '')
                .replace(/[\.\.\.]+$/, '')
                .trim();
            if (cleanPh) return cleanPh;
        }

        // 5. Title
        var title = field.getAttribute('title');
        if (title && title.trim()) {
            return title.trim();
        }

        // 6. Name attribute
        var name = field.getAttribute('name');
        if (name && name.trim()) {
            return name.trim();
        }

        return 'Trường này';
    }

    function showFieldError(field, customMsg) {
        if (!field) return;
        clearFieldError(field);

        var fieldName = getFieldName(field);
        var msg = customMsg || (fieldName + ' không được để trống');

        field.classList.add('has-field-error');
        field.style.borderColor = '#dc2626';

        var errorEl = document.createElement('div');
        errorEl.className = 'field-error-msg';
        errorEl.style.color = '#dc2626';
        errorEl.style.fontSize = '12px';
        errorEl.style.marginTop = '4px';
        errorEl.style.marginBottom = '4px';
        errorEl.style.fontWeight = '500';
        errorEl.style.display = 'block';
        errorEl.style.textAlign = 'left';
        errorEl.style.lineHeight = '1.4';
        errorEl.textContent = msg;

        // Place after field or after .input-group wrapper
        var target = field;
        if (field.parentElement && (field.parentElement.classList.contains('input-group') || field.parentElement.classList.contains('input-wrapper'))) {
            target = field.parentElement;
        }
        if (target.nextSibling) {
            target.parentNode.insertBefore(errorEl, target.nextSibling);
        } else {
            target.parentNode.appendChild(errorEl);
        }
    }

    function clearFieldError(field) {
        if (!field) return;
        field.classList.remove('has-field-error');
        field.style.borderColor = '';

        var target = field;
        if (field.parentElement && (field.parentElement.classList.contains('input-group') || field.parentElement.classList.contains('input-wrapper'))) {
            target = field.parentElement;
        }
        var parent = target.parentNode;
        if (parent) {
            var next = target.nextElementSibling;
            while (next && next.classList.contains('field-error-msg')) {
                var toRemove = next;
                next = next.nextElementSibling;
                toRemove.remove();
            }
        }
    }

    // Live clearing on typing or selecting
    document.addEventListener('input', function (e) {
        if (e.target && (e.target.tagName === 'INPUT' || e.target.tagName === 'TEXTAREA')) {
            clearFieldError(e.target);
        }
    }, true);

    document.addEventListener('change', function (e) {
        if (e.target && (e.target.tagName === 'SELECT' || e.target.tagName === 'INPUT' || e.target.tagName === 'TEXTAREA')) {
            clearFieldError(e.target);
        }
    }, true);

    // Form submit validation handler
    document.addEventListener('submit', function (e) {
        var form = e.target;
        if (!form || form.tagName !== 'FORM') return;

        var fields = form.querySelectorAll('input, select, textarea');
        var firstError = null;
        var hasError = false;

        for (var i = 0; i < fields.length; i++) {
            var field = fields[i];

            // Ignore hidden, disabled, buttons
            if (field.type === 'hidden' || field.type === 'submit' || field.type === 'button' || field.type === 'reset' || field.disabled) {
                continue;
            }

            clearFieldError(field);

            var isRequired = field.hasAttribute('required') || field.required;
            if (isRequired) {
                var isBlank = false;
                if (field.type === 'radio') {
                    if (field.name) {
                        try {
                            var checkedRadio = form.querySelector('input[type="radio"][name="' + CSS.escape(field.name) + '"]:checked');
                            if (!checkedRadio) isBlank = true;
                        } catch (err) {
                            if (!field.checked) isBlank = true;
                        }
                    } else if (!field.checked) {
                        isBlank = true;
                    }
                } else if (field.type === 'checkbox') {
                    if (!field.checked) isBlank = true;
                } else {
                    var val = (field.value !== undefined && field.value !== null) ? field.value.trim() : '';
                    if (val === '') isBlank = true;
                }

                if (isBlank) {
                    showFieldError(field);
                    hasError = true;
                    if (!firstError) firstError = field;
                }
            }
        }

        if (hasError) {
            e.preventDefault();
            e.stopPropagation();
            if (firstError) {
                try {
                    firstError.focus();
                    if (typeof firstError.scrollIntoView === 'function') {
                        firstError.scrollIntoView({ behavior: 'smooth', block: 'center' });
                    }
                } catch (err) {}
            }
        }
    }, true);
})();

