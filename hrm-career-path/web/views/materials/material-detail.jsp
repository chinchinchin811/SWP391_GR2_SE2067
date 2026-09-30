<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List,model.LearningMaterial,model.VideoCheckpoint,model.User" %>
<%
    LearningMaterial material = (LearningMaterial) request.getAttribute("material");
    List<VideoCheckpoint> checkpoints = (List<VideoCheckpoint>) request.getAttribute("checkpoints");
    String fromClassId = request.getParameter("classId");
    User currentUser = (User) session.getAttribute("currentUser");
    boolean canManage = currentUser != null && currentUser.getRoleId() <= 3;
    request.setAttribute("pageTitle", (material != null ? material.getTitle() : "Học liệu") + " | HRM");
%>
<jsp:include page="/views/common/header.jsp" />
<jsp:include page="/views/common/sidebar.jsp" />
<main class="main-content">
    <div class="topbar">
        <h1><%= material != null ? material.getTitle() : "" %></h1>
        <div class="topbar-actions">
            <% if (fromClassId != null && !fromClassId.trim().isEmpty()) { %>
            <a class="btn btn-secondary" href="<%= request.getContextPath() %>/materials?action=classDetail&id=<%= fromClassId %>">Quay lại lớp học</a>
            <% } else { %>
            <a class="btn btn-secondary" href="<%= request.getContextPath() %>/materials">Quay lại kho học liệu</a>
            <% } %>
            <% if (material != null) { %>
            <a class="btn btn-primary" href="<%= request.getContextPath() %>/materials?action=download&id=<%= material.getMaterialId() %>">Tải xuống</a>
            <% if (canManage) { %>
            <a class="btn btn-secondary" href="<%= request.getContextPath() %>/materials?action=edit&id=<%= material.getMaterialId() %>">Sửa</a>
            <form method="post" action="<%= request.getContextPath() %>/materials" style="display:inline-flex;margin:0" onsubmit="return confirm('Bạn có chắc chắn muốn xóa học liệu này?')">
                <input type="hidden" name="action" value="deleteMaterial">
                <input type="hidden" name="id" value="<%= material.getMaterialId() %>">
                <button type="submit" class="btn btn-danger">Xóa học liệu</button>
            </form>
            <% } %>
            <% } %>
        </div>
    </div>
    <div class="content-body">
        <% if (material != null) { %>
        <div class="card">
            <div class="card-header">
                <h2>Thông Tin Học Liệu</h2>
                <span class="badge"><%= material.getMaterialType() %></span>
            </div>
            <div class="card-body">
                <p style="font-size:13px;color:#333;line-height:1.6">
                    <%= material.getDescription() != null ? material.getDescription() : "<em style='color:#999'>Chưa có mô tả.</em>" %>
                </p>
                <p style="margin-top:10px;font-size:13px">
                    <strong>Thời lượng:</strong> <%= material.getDurationMinutes() %> phút
                </p>
            </div>
        </div>

        <div class="card">
            <div class="card-header">
                <h2>Nội Dung Học Liệu</h2>
            </div>
            <div class="card-body" style="padding:0">
                <% if ("VIDEO".equals(material.getMaterialType()) && material.getYoutubeEmbedId() != null) { %>
                <div id="youtubePlayer" style="width:100%;min-height:480px;background:#000"></div>
                <% } else if ("VIDEO".equals(material.getMaterialType()) && material.getVideoUrl() != null && !material.getVideoUrl().trim().isEmpty()) { %>
                <video id="learningVideo" controls style="width:100%;max-height:600px;display:block">
                    <source src="<%= material.getVideoUrl() %>">
                </video>
                <% } else if ("PDF".equals(material.getMaterialType())) { %>
                    <% if (material.getPdfEmbedUrl() != null) { %>
                    <div style="background:#f8f9fa;border-bottom:1px solid #ddd;padding:8px 14px;display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:10px">
                        <div style="display:flex;align-items:center;gap:8px">
                            <span class="badge" style="background:#2c3e50;color:#fff;font-weight:600">PDF Trực Tuyến</span>
                            <span style="font-size:12.5px;color:#555">Đang xem tài liệu từ liên kết web</span>
                        </div>
                        <div style="display:flex;align-items:center;gap:8px">
                            <button type="button" class="btn btn-secondary" onclick="togglePdfSource()" style="font-size:12px;padding:4px 10px" id="togglePdfBtn">
                                Đổi chế độ xem (Google Docs Viewer)
                            </button>
                            <a class="btn btn-primary" href="<%= material.getVideoUrl() %>" target="_blank" style="font-size:12px;padding:4px 12px">
                                Mở tab mới ↗
                            </a>
                        </div>
                    </div>
                    <iframe id="pdfFrame" title="<%= material.getTitle() %>"
                            src="<%= material.getPdfEmbedUrl() %>"
                            style="width:100%;height:700px;border:none"
                            allow="autoplay"></iframe>
                    <script>
                        let isGoogleDocsMode = false;
                        const originalPdfUrl = <%= json(material.getPdfEmbedUrl()) %>;
                        const gdocsPdfUrl = <%= json(material.getGoogleDocsViewerUrl()) %>;
                        function togglePdfSource() {
                            const frame = document.getElementById('pdfFrame');
                            const btn = document.getElementById('togglePdfBtn');
                            if (!frame) return;
                            isGoogleDocsMode = !isGoogleDocsMode;
                            if (isGoogleDocsMode) {
                                frame.src = gdocsPdfUrl;
                                btn.textContent = 'Đổi sang Trình xem trực tiếp';
                            } else {
                                frame.src = originalPdfUrl;
                                btn.textContent = 'Đổi sang Google Docs Viewer';
                            }
                        }
                    </script>
                    <% } else if (material.getFileName() != null && !material.getFileName().isEmpty()) { %>
                    <div style="background:#f8f9fa;border-bottom:1px solid #ddd;padding:8px 14px;display:flex;align-items:center;justify-content:space-between">
                        <span style="font-size:12.5px;color:#555">
                            <strong>Tệp đính kèm:</strong> <%= material.getFileName() %>
                        </span>
                        <a class="btn btn-secondary" href="<%= request.getContextPath() %>/materials?action=download&id=<%= material.getMaterialId() %>" style="font-size:12px;padding:4px 10px">
                            Tải xuống tệp
                        </a>
                    </div>
                    <iframe title="<%= material.getTitle() %>"
                            src="<%= request.getContextPath() %>/materials?action=preview&id=<%= material.getMaterialId() %>"
                            style="width:100%;height:700px;border:none"></iframe>
                    <% } else { %>
                    <div style="padding:48px 24px;text-align:center;color:#666">
                        <div style="font-size:40px;margin-bottom:12px">📄</div>
                        <h3 style="font-size:16px;color:#333;margin-bottom:8px">Chưa có tệp PDF hoặc liên kết trực tuyến</h3>
                        <p style="font-size:13px;color:#777;max-width:480px;margin:0 auto 16px;line-height:1.6">
                            Học liệu này chưa được đính kèm tệp PDF hoặc gắn liên kết xem trực tuyến. Bạn có thể nhấn Sửa để gắn liên kết Google Drive / PDF công khai.
                        </p>
                        <a class="btn btn-primary" href="<%= request.getContextPath() %>/materials?action=edit&id=<%= material.getMaterialId() %>">
                            Sửa và Gắn Liên Kết
                        </a>
                    </div>
                    <% } %>
                <% } else if ("SLIDE".equals(material.getMaterialType()) && material.getSlideEmbedUrl() != null) { %>
                <iframe title="<%= material.getTitle() %>"
                        src="<%= material.getSlideEmbedUrl() %>"
                        allowfullscreen
                        style="width:100%;height:650px;border:none"></iframe>
                <% } else { %>
                <div style="padding:32px;text-align:center;color:#666;font-size:13px;line-height:1.7">
                    Slide tải lên từ máy không thể xem trực tiếp trên trình duyệt.<br>
                    Hãy cập nhật liên kết công khai Google Slides, Google Drive hoặc Office Online để trình chiếu tại đây.
                </div>
                <% } %>
            </div>
        </div>
        <% } %>
    </div>
</main>

<div id="questionModal" style="display:none;position:fixed;inset:0;background:rgba(0,0,0,.75);z-index:99999;align-items:center;justify-content:center;backdrop-filter:blur(2px)">
    <div style="width:540px;max-width:92%;background:#fff;border:1px solid #111;box-shadow:0 12px 36px rgba(0,0,0,0.35);padding:24px;border-radius:6px">
        <div style="display:flex;align-items:center;justify-content:space-between;margin-bottom:14px;border-bottom:1px solid #eee;padding-bottom:10px">
            <h3 style="font-size:16px;font-weight:700;margin:0;color:#111">
                <span style="display:inline-block;width:8px;height:8px;background:#e74c3c;border-radius:50%;margin-right:6px"></span>
                Câu Hỏi Dừng Video (Kiểm Tra Nhanh)
            </h3>
            <span style="font-size:11px;padding:3px 8px;background:#f0f0f0;color:#555;border-radius:3px;font-weight:600">TƯƠNG TÁC</span>
        </div>
        <p id="questionText" style="font-size:14px;font-weight:600;margin-bottom:14px;color:#222;line-height:1.5"></p>
        <div id="options" style="margin-bottom:14px"></div>
        <div id="feedback" style="font-size:13px;margin-bottom:14px;min-height:20px;line-height:1.5"></div>
        <div id="modalActions">
            <button id="submitAnswer" class="btn btn-primary" style="width:100%;padding:10px;font-size:14px;font-weight:600">Gửi câu trả lời</button>
        </div>
    </div>
</div>

<script>
    const checkpoints = [
        <% if (checkpoints != null) {
            for (int i = 0; i < checkpoints.size(); i++) {
                VideoCheckpoint c = checkpoints.get(i);
                if (i > 0) out.print(",");
        %>
            {id: <%= c.getCheckpointId() %>, seconds: <%= c.getStopTimeSeconds() %>, question: <%= json(c.getQuestionPrompt()) %>, options: [<%= json(c.getOptionA()) %>, <%= json(c.getOptionB()) %>, <%= json(c.getOptionC()) %>, <%= json(c.getOptionD()) %>]}
        <%  }
        } %>
    ];
    checkpoints.sort((a, b) => a.seconds - b.seconds);

    let answered = new Set();
    let activeCheckpoint = null;
    let videoElement = null;
    let youtubePlayer = null;
    let youtubeTimer = null;
    let rewindTimeout = null;

    const modal = document.getElementById('questionModal');
    const questionText = document.getElementById('questionText');
    const optionsContainer = document.getElementById('options');
    const feedback = document.getElementById('feedback');
    const submitBtn = document.getElementById('submitAnswer');
    const modalActions = document.getElementById('modalActions');

    function escapeHtml(text) {
        if (!text) return '';
        return String(text).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
    }

    function formatTime(totalSeconds) {
        const m = Math.floor(totalSeconds / 60);
        const s = Math.floor(totalSeconds % 60);
        return (m < 10 ? '0' : '') + m + ':' + (s < 10 ? '0' : '') + s;
    }

    // Helper: Triệt để dừng toàn bộ phát video (cả HTML5 Video và YouTube Iframe)
    function pauseAll() {
        if (videoElement) {
            try { videoElement.pause(); } catch(e) {}
        }
        if (youtubePlayer && typeof youtubePlayer.pauseVideo === 'function') {
            try { youtubePlayer.pauseVideo(); } catch(e) {}
        }
        // Fallback postMessage trực tiếp tới iframe của YouTube
        try {
            const iframes = document.querySelectorAll('iframe');
            iframes.forEach(function(f) {
                if (f.contentWindow) {
                    f.contentWindow.postMessage(JSON.stringify({event: 'command', func: 'pauseVideo', args: []}), '*');
                }
            });
        } catch(e) {}
    }

    // Helper: Tiếp tục phát video
    function playAll() {
        if (videoElement) {
            try { videoElement.play(); } catch(e) {}
        }
        if (youtubePlayer && typeof youtubePlayer.playVideo === 'function') {
            try { youtubePlayer.playVideo(); } catch(e) {}
        }
        try {
            const iframes = document.querySelectorAll('iframe');
            iframes.forEach(function(f) {
                if (f.contentWindow) {
                    f.contentWindow.postMessage(JSON.stringify({event: 'command', func: 'playVideo', args: []}), '*');
                }
            });
        } catch(e) {}
    }

    // Helper: Tua video tới mốc giây chỉ định
    function seekAll(targetSeconds) {
        if (videoElement) {
            try { videoElement.currentTime = targetSeconds; } catch(e) {}
        }
        if (youtubePlayer && typeof youtubePlayer.seekTo === 'function') {
            try { youtubePlayer.seekTo(targetSeconds, true); } catch(e) {}
        }
        try {
            const iframes = document.querySelectorAll('iframe');
            iframes.forEach(function(f) {
                if (f.contentWindow) {
                    f.contentWindow.postMessage(JSON.stringify({event: 'command', func: 'seekTo', args: [targetSeconds, true]}), '*');
                }
            });
        } catch(e) {}
    }

    function pauseForCheckpoint(checkpoint) {
        if (activeCheckpoint || answered.has(checkpoint.id)) return;
        activeCheckpoint = checkpoint;

        // Dừng video ngay lập tức và gọi lại nhiều lần để xử lý độ trễ buffer YouTube
        pauseAll();
        setTimeout(pauseAll, 60);
        setTimeout(pauseAll, 150);
        setTimeout(pauseAll, 300);

        questionText.textContent = checkpoint.question;
        feedback.innerHTML = '';

        let html = '';
        checkpoint.options.forEach((opt, idx) => {
            if (opt) {
                html += '<label class="checkpoint-option-label" style="display:flex;align-items:center;padding:10px 12px;margin:7px 0;border:1px solid #ddd;border-radius:4px;cursor:pointer;background:#fafafa;font-size:13.5px;transition:all 0.15s">'
                     + '<input type="radio" name="answer" value="' + idx + '" style="margin-right:10px;cursor:pointer"> '
                     + '<span>' + escapeHtml(opt) + '</span>'
                     + '</label>';
            }
        });
        optionsContainer.innerHTML = html;

        // Cho phép click vào cả dòng để chọn phương án
        document.querySelectorAll('.checkpoint-option-label').forEach(label => {
            label.addEventListener('click', function() {
                document.querySelectorAll('.checkpoint-option-label').forEach(l => {
                    l.style.borderColor = '#ddd';
                    l.style.background = '#fafafa';
                });
                label.style.borderColor = '#000';
                label.style.background = '#f4f4f4';
                const r = label.querySelector('input[type=radio]');
                if (r) r.checked = true;
            });
        });

        modalActions.innerHTML = '<button id="submitAnswer" class="btn btn-primary" style="width:100%;padding:10px;font-size:14px;font-weight:600">Gửi câu trả lời</button>';
        attachSubmitHandler();

        modal.style.display = 'flex';
    }

    function checkPlaybackTime(currentTime) {
        if (activeCheckpoint) {
            pauseAll();
            return;
        }
        for (const checkpoint of checkpoints) {
            if (!answered.has(checkpoint.id) && currentTime >= checkpoint.seconds) {
                pauseForCheckpoint(checkpoint);
                break;
            }
        }
    }

    function executeRewindAndResume(targetSeconds) {
        if (rewindTimeout) {
            clearTimeout(rewindTimeout);
            rewindTimeout = null;
        }
        activeCheckpoint = null;
        modal.style.display = 'none';
        feedback.innerHTML = '';

        // Tua video về 15s trước và tiếp tục phát
        seekAll(targetSeconds);
        setTimeout(function() {
            playAll();
        }, 200);
    }

    function attachSubmitHandler() {
        const btn = document.getElementById('submitAnswer');
        if (!btn) return;
        btn.addEventListener('click', async function() {
            const choice = document.querySelector('input[name=answer]:checked');
            if (!choice) {
                feedback.innerHTML = '<div style="color:#c0392b;font-weight:600;padding:6px 0">⚠️ Vui lòng chọn một phương án trả lời.</div>';
                return;
            }
            if (!activeCheckpoint) return;

            btn.disabled = true;
            btn.textContent = 'Đang kiểm tra...';

            try {
                const response = await fetch('<%= request.getContextPath() %>/materials', {
                    method: 'POST',
                    headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                    body: new URLSearchParams({
                        action: 'answerCheckpoint',
                        checkpointId: activeCheckpoint.id,
                        selectedOption: choice.value
                    })
                });
                const result = await response.json();

                if (result.correct) {
                    feedback.innerHTML = '<div style="padding:10px 14px;background:#e8f8f5;border:1px solid #27ae60;color:#1e8449;border-radius:4px;font-size:13px">'
                        + '<strong>✓ Chính xác!</strong> ' + (result.explanation || 'Bạn đã hoàn thành câu hỏi kiến thức này.')
                        + '</div>';
                    answered.add(activeCheckpoint.id);

                    setTimeout(function() {
                        activeCheckpoint = null;
                        modal.style.display = 'none';
                        feedback.innerHTML = '';
                        playAll();
                    }, 1200);
                } else {
                    const checkpointSec = activeCheckpoint.seconds;
                    const rewindTarget = Math.max(0, checkpointSec - 15);

                    feedback.innerHTML = '<div style="padding:12px 14px;background:#fef5e7;border:1px solid #e67e22;color:#935116;border-radius:4px;font-size:13px;line-height:1.6">'
                        + '<div style="font-weight:700;color:#c0392b;margin-bottom:4px">✕ Trả lời chưa chính xác!</div>'
                        + (result.explanation ? '<div>' + escapeHtml(result.explanation) + '</div>' : '')
                        + '<div style="margin-top:8px;font-weight:600;color:#2c3e50">'
                        + '⏱️ Đang tua lại 15 giây (về <strong>' + formatTime(rewindTarget) + '</strong>) để bạn xem lại bài giảng...'
                        + '</div>'
                        + '</div>';

                    modalActions.innerHTML = '<button type="button" id="rewindNowBtn" class="btn btn-secondary" style="width:100%;padding:10px;font-size:13.5px;font-weight:600">Tua lại ngay (' + formatTime(rewindTarget) + ') &amp; Tiếp tục xem</button>';
                    const rewindBtn = document.getElementById('rewindNowBtn');
                    if (rewindBtn) {
                        rewindBtn.addEventListener('click', function() {
                            executeRewindAndResume(rewindTarget);
                        });
                    }

                    // Tự động tua lại và ẩn modal sau 2.2 giây để người dùng theo dõi lại
                    rewindTimeout = setTimeout(function() {
                        executeRewindAndResume(rewindTarget);
                    }, 2200);
                }
            } catch(e) {
                console.error('Error submitting checkpoint answer:', e);
                feedback.innerHTML = '<div style="color:#c0392b;padding:6px 0">Có lỗi khi gửi đáp án. Vui lòng thử lại.</div>';
                btn.disabled = false;
                btn.textContent = 'Gửi câu trả lời';
            }
        });
    }

    <% if (material != null && "VIDEO".equals(material.getMaterialType()) && material.getYoutubeEmbedId() != null) { %>
        function initYouTubePlayer() {
            if (youtubePlayer) return;
            youtubePlayer = new YT.Player('youtubePlayer', {
                videoId: '<%= material.getYoutubeEmbedId() %>',
                playerVars: {
                    'autoplay': 0,
                    'enablejsapi': 1,
                    'origin': window.location.origin,
                    'rel': 0
                },
                events: {
                    onStateChange: function(event) {
                        if (event.data === YT.PlayerState.PLAYING) {
                            if (activeCheckpoint) {
                                pauseAll();
                                return;
                            }
                            if (youtubeTimer === null) {
                                youtubeTimer = window.setInterval(function() {
                                    if (activeCheckpoint) {
                                        pauseAll();
                                        return;
                                    }
                                    if (youtubePlayer && typeof youtubePlayer.getCurrentTime === 'function') {
                                        checkPlaybackTime(youtubePlayer.getCurrentTime());
                                    }
                                }, 250);
                            }
                        } else if (event.data === YT.PlayerState.PAUSED || event.data === YT.PlayerState.ENDED) {
                            if (youtubeTimer !== null) {
                                clearInterval(youtubeTimer);
                                youtubeTimer = null;
                            }
                        }
                    }
                }
            });
        }

        window.onYouTubeIframeAPIReady = function() {
            initYouTubePlayer();
        };

        if (window.YT && window.YT.Player) {
            initYouTubePlayer();
        } else {
            var youtubeApi = document.createElement('script');
            youtubeApi.src = 'https://www.youtube.com/iframe_api';
            document.head.appendChild(youtubeApi);
        }
    <% } else { %>
        videoElement = document.getElementById('learningVideo');
        if (videoElement) {
            videoElement.addEventListener('timeupdate', function() {
                if (activeCheckpoint) {
                    videoElement.pause();
                    return;
                }
                checkPlaybackTime(videoElement.currentTime);
            });
            videoElement.addEventListener('play', function() {
                if (activeCheckpoint) {
                    videoElement.pause();
                }
            });
        }
    <% } %>

    attachSubmitHandler();
</script>
<%!
    String json(String s) {
        return s == null ? "null" : "\"" + s.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", " ").replace("\r", " ") + "\"";
    }
%>
<jsp:include page="/views/common/footer.jsp" />
