<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*,model.*,service.TestService" %>
<%@ page import="static utils.TestView.h" %>
<%
    TestActor setActor=(TestActor)request.getAttribute("testActor");
    TestService.ContentDetail editingSet=(TestService.ContentDetail)request.getAttribute("editingSet");
    boolean editing=editingSet!=null;
    TestContent setContent=editing ? editingSet.content() : null;
    String setBase=request.getContextPath()+"/tests";
    String setCsrf=(String)session.getAttribute("testCsrf");
%>
<section class="card">
    <div class="card-header">
        <h2><%= editing ? "Chỉnh sửa bộ đề" : "Tạo bộ đề kiểm tra riêng" %></h2>
    </div>
    <div class="card-body">
        <form method="post" action="<%= setBase %>" class="test-form" id="customSetForm">
            <input type="hidden" name="csrf" value="<%= h(setCsrf) %>">
            <input type="hidden" name="action" value="<%= editing ? "updateSet" : "createSet" %>">
            <% if(editing) { %><input type="hidden" name="id" value="<%= setContent.id() %>"><% } %>
            <input type="hidden" name="questionCount" id="questionCount" value="0">

            <label>Tên bộ đề
                <input name="title" maxlength="200" required placeholder="Ví dụ: Kiểm tra Java Core - Junior"
                       value="<%= editing ? h(setContent.title()) : "" %>">
            </label>
            <label>Loại bộ đề
                <select name="type" required>
                    <% if(setActor.cultureManager()) { %><option value="culture" <%= editing && "culture".equals(setContent.type()) ? "selected" : "" %>>Văn hóa doanh nghiệp</option><% } %>
                    <% if(setActor.professionalManager()) { %><option value="department" <%= editing && "department".equals(setContent.type()) ? "selected" : "" %>>Chuyên môn</option><% } %>
                </select>
            </label>
            <label>Mô tả / hướng dẫn
                <textarea name="description" maxlength="20000" rows="5" placeholder="Mô tả mục tiêu và hướng dẫn làm bài"><%= editing ? h(setContent.prompt()) : "" %></textarea>
            </label>

            <div class="set-editor-heading">
                <div><h3>Câu hỏi</h3><p>Hỗ trợ chọn một, chọn nhiều và đúng/sai.</p></div>
            </div>
            <div id="setQuestionList" class="set-question-list">
                <% if(editing) { for(TestQuestion question:editingSet.questions()) { %>
                <section class="set-question-editor">
                    <div class="set-question-editor-header">
                        <h3 class="set-question-number">Câu hỏi</h3>
                        <button type="button" class="set-remove-question">Xóa câu</button>
                    </div>
                    <label>Nội dung câu hỏi
                        <textarea class="set-question-prompt" maxlength="4000" rows="3" required><%= h(question.prompt()) %></textarea>
                    </label>
                    <label>Loại câu hỏi
                        <select class="set-question-type">
                            <option value="single" <%= "single".equals(question.type()) ? "selected" : "" %>>Chọn một đáp án</option>
                            <option value="multiple" <%= "multiple".equals(question.type()) ? "selected" : "" %>>Chọn nhiều đáp án</option>
                            <option value="true_false" <%= "true_false".equals(question.type()) ? "selected" : "" %>>Đúng / Sai</option>
                        </select>
                    </label>
                    <div class="set-options">
                        <% for(TestQuestionOption option:question.options()) { %>
                        <div class="set-option-editor">
                            <input class="set-correct-option" type="<%= "multiple".equals(question.type()) ? "checkbox" : "radio" %>"
                                   aria-label="Đáp án đúng" <%= Boolean.TRUE.equals(option.correct()) ? "checked" : "" %>>
                            <input class="set-option-text" maxlength="1000" required placeholder="Nội dung đáp án" value="<%= h(option.text()) %>">
                            <button type="button" class="set-remove-option">Xóa</button>
                        </div>
                        <% } %>
                    </div>
                    <button type="button" class="set-inline-action set-add-option" <%= "true_false".equals(question.type()) ? "hidden" : "" %>>+ Thêm đáp án</button>
                </section>
                <% } } %>
            </div>
            <button type="button" class="btn btn-secondary set-add-question-bar" id="addQuestionButton">+ Thêm câu hỏi</button>

            <div class="test-form-actions">
                <a class="btn btn-secondary" href="<%= editing ? setBase+"?action=bankDetail&amp;id="+setContent.id() : setBase+"?action=bank" %>">Hủy</a>
                <button class="btn btn-primary" id="saveSetButton"><%= editing ? "Lưu thay đổi" : "Lưu bộ đề" %></button>
            </div>
        </form>
    </div>
</section>

<template id="setQuestionTemplate">
    <section class="set-question-editor">
        <div class="set-question-editor-header">
            <h3 class="set-question-number">Câu hỏi</h3>
            <button type="button" class="set-remove-question">Xóa câu</button>
        </div>
        <label>Nội dung câu hỏi
            <textarea class="set-question-prompt" maxlength="4000" rows="3" required></textarea>
        </label>
        <label>Loại câu hỏi
            <select class="set-question-type">
                <option value="single">Chọn một đáp án</option>
                <option value="multiple">Chọn nhiều đáp án</option>
                <option value="true_false">Đúng / Sai</option>
            </select>
        </label>
        <div class="set-options"></div>
        <button type="button" class="set-inline-action set-add-option">+ Thêm đáp án</button>
    </section>
</template>

<script>
    (function () {
        var list = document.getElementById('setQuestionList');
        var template = document.getElementById('setQuestionTemplate');
        var count = document.getElementById('questionCount');

        function wireOption(row) {
            if (row.dataset.wired === 'true')
                return;
            row.dataset.wired = 'true';
            row.querySelector('.set-remove-option').addEventListener('click', function () {
                if (row.parentElement.children.length > 2)
                    row.remove();
                renumber();
            });
        }

        function optionRow(text, correct) {
            var row = document.createElement('div');
            row.className = 'set-option-editor';
            var mark = document.createElement('input');
            mark.className = 'set-correct-option';
            mark.type = 'radio';
            mark.setAttribute('aria-label', 'Đáp án đúng');
            var input = document.createElement('input');
            input.className = 'set-option-text';
            input.maxLength = 1000;
            input.required = true;
            input.placeholder = 'Nội dung đáp án';
            input.value = text || '';
            var remove = document.createElement('button');
            remove.type = 'button';
            remove.className = 'set-remove-option';
            remove.textContent = 'Xóa';
            row.append(mark, input, remove);
            if (correct)
                mark.checked = true;
            wireOption(row);
            return row;
        }

        function configureType(section) {
            var type = section.querySelector('.set-question-type').value;
            var options = section.querySelector('.set-options');
            var add = section.querySelector('.set-add-option');
            if (type === 'true_false') {
                options.replaceChildren(optionRow('Đúng', true), optionRow('Sai', false));
                add.hidden = true;
            } else {
                add.hidden = false;
                Array.prototype.forEach.call(options.querySelectorAll('.set-correct-option'), function (mark) {
                    mark.type = type === 'multiple' ? 'checkbox' : 'radio';
                });
            }
            renumber();
        }

        function wireSection(section) {
            var options = section.querySelector('.set-options');
            Array.prototype.forEach.call(options.querySelectorAll('.set-option-editor'), wireOption);
            section.querySelector('.set-add-option').addEventListener('click', function () {
                if (options.children.length < 20)
                    options.append(optionRow('', false));
                renumber();
            });
            section.querySelector('.set-question-type').addEventListener('change', function () {
                configureType(section);
            });
            section.querySelector('.set-remove-question').addEventListener('click', function () {
                section.remove();
                renumber();
            });
        }

        function addQuestion() {
            if (list.children.length >= 100)
                return;
            var section = template.content.firstElementChild.cloneNode(true);
            section.querySelector('.set-options').append(optionRow('', true), optionRow('', false));
            wireSection(section);
            list.append(section);
            renumber();
        }

        function renumber() {
            Array.prototype.forEach.call(list.children, function (section, index) {
                section.querySelector('.set-question-number').textContent = 'Câu ' + (index + 1);
                section.querySelector('.set-question-prompt').name = 'questionPrompt_' + index;
                section.querySelector('.set-question-type').name = 'questionType_' + index;
                var options = section.querySelectorAll('.set-option-editor');
                var hidden = section.querySelector('.set-option-count');
                if (!hidden) {
                    hidden = document.createElement('input');
                    hidden.type = 'hidden';
                    hidden.className = 'set-option-count';
                    section.append(hidden);
                }
                hidden.name = 'optionCount_' + index;
                hidden.value = options.length;
                Array.prototype.forEach.call(options, function (row, optionIndex) {
                    row.querySelector('.set-option-text').name = 'option_' + index + '_' + optionIndex;
                    var mark = row.querySelector('.set-correct-option');
                    mark.name = 'correct_' + index;
                    mark.value = optionIndex;
                    mark.type = section.querySelector('.set-question-type').value === 'multiple' ? 'checkbox' : 'radio';
                });
            });
            count.value = list.children.length;
        }

        document.getElementById('addQuestionButton').addEventListener('click', addQuestion);
        document.getElementById('customSetForm').addEventListener('submit', function (event) {
            renumber();
            if (list.children.length === 0) {
                event.preventDefault();
                window.alert('Bộ đề sẵn sàng phải có ít nhất một câu hỏi.');
                return;
            }
            var button = document.getElementById('saveSetButton');
            button.disabled = true;
            button.textContent = 'Đang lưu...';
        });
        Array.prototype.forEach.call(list.children, wireSection);
        if (list.children.length === 0)
            addQuestion();
        renumber();
    })();
</script>
