<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List,model.LearningMaterial,model.VideoCheckpoint" %>
<%
    LearningMaterial material = (LearningMaterial) request.getAttribute("material");
    List<VideoCheckpoint> checkpoints = (List<VideoCheckpoint>) request.getAttribute("checkpoints");
    request.setAttribute("pageTitle", material.getTitle() + " | HRM");
%>
<jsp:include page="/views/common/header.jsp" />
<jsp:include page="/views/common/sidebar.jsp" />
<main class="main-content">
    <div class="topbar">
        <h1><%= material.getTitle() %></h1>
        <div class="topbar-actions">
            <a class="btn btn-secondary" href="<%= request.getContextPath() %>/materials">Quay lại kho học liệu</a>
            <a class="btn btn-primary" href="<%= request.getContextPath() %>/materials?action=download&id=<%= material.getMaterialId() %>">Tải xuống</a>
        </div>
    </div>
    <div class="content-body">
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
                <iframe title="<%= material.getTitle() %>"
                        src="<%= request.getContextPath() %>/materials?action=preview&id=<%= material.getMaterialId() %>"
                        style="width:100%;height:650px;border:none"></iframe>
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
    </div>
</main>

<div id="questionModal" style="display:none;position:fixed;inset:0;background:rgba(0,0,0,.5);z-index:100;align-items:center;justify-content:center">
    <div style="width:500px;max-width:90%;background:#fff;border:1px solid #000;padding:24px">
        <h3 style="font-size:15px;margin-bottom:12px;border-bottom:1px solid #000;padding-bottom:10px">Kiểm tra kiến thức</h3>
        <p id="questionText" style="font-size:13.5px;font-weight:600;margin-bottom:10px"></p>
        <div id="options" style="margin-bottom:12px"></div>
        <p id="feedback" style="font-size:12.5px;color:#555;margin-bottom:12px;min-height:18px"></p>
        <button id="submitAnswer" class="btn btn-primary" style="width:100%">Gửi câu trả lời</button>
    </div>
</div>

<script>
const checkpoints=[<%if(checkpoints!=null){for(int i=0;i<checkpoints.size();i++){VideoCheckpoint c=checkpoints.get(i);if(i>0)out.print(",");%>{id:<%=c.getCheckpointId()%>,seconds:<%=c.getStopTimeSeconds()%>,question:<%=json(c.getQuestionPrompt())%>,options:[<%=json(c.getOptionA())%>,<%=json(c.getOptionB())%>,<%=json(c.getOptionC())%>,<%=json(c.getOptionD())%>]}<%}}%>];
let answered=new Set(),activeCheckpoint=null,videoElement=null,youtubePlayer=null,youtubeTimer=null;
const modal=document.getElementById('questionModal'),questionText=document.getElementById('questionText'),options=document.getElementById('options'),feedback=document.getElementById('feedback');
function pauseForCheckpoint(checkpoint){if(activeCheckpoint||answered.has(checkpoint.id))return;activeCheckpoint=checkpoint;if(videoElement)videoElement.pause();if(youtubePlayer)youtubePlayer.pauseVideo();questionText.textContent=checkpoint.question;feedback.textContent='';options.innerHTML=checkpoint.options.map((option,index)=>option?'<label style="display:block;padding:8px;margin:5px 0;border:1px solid #ddd;cursor:pointer"><input type="radio" name="answer" value="'+index+'"> '+option+'</label>':'').join('');modal.style.display='flex';}
function checkPlaybackTime(currentTime){if(activeCheckpoint)return;for(const checkpoint of checkpoints){if(!answered.has(checkpoint.id)&&currentTime>=checkpoint.seconds){pauseForCheckpoint(checkpoint);break;}}}
document.getElementById('submitAnswer').addEventListener('click',async function(){const choice=document.querySelector('input[name=answer]:checked');if(!choice||!activeCheckpoint)return;const response=await fetch('<%=request.getContextPath()%>/materials',{method:'POST',headers:{'Content-Type':'application/x-www-form-urlencoded'},body:new URLSearchParams({action:'answerCheckpoint',checkpointId:activeCheckpoint.id,selectedOption:choice.value})});const result=await response.json();if(result.correct){answered.add(activeCheckpoint.id);activeCheckpoint=null;modal.style.display='none';if(videoElement)videoElement.play();if(youtubePlayer)youtubePlayer.playVideo();}else{feedback.textContent='Chưa đúng. '+(result.explanation||'Hãy xem lại đoạn video và thử lại.');if(videoElement)videoElement.currentTime=Math.max(0,videoElement.currentTime-15);if(youtubePlayer)youtubePlayer.seekTo(Math.max(0,youtubePlayer.getCurrentTime()-15),true);}});
<%if("VIDEO".equals(material.getMaterialType())&&material.getYoutubeEmbedId()!=null){%>
function onYouTubeIframeAPIReady(){youtubePlayer=new YT.Player('youtubePlayer',{videoId:'<%=material.getYoutubeEmbedId()%>',events:{onStateChange:function(event){if(event.data===YT.PlayerState.PLAYING&&youtubeTimer===null){youtubeTimer=window.setInterval(function(){checkPlaybackTime(youtubePlayer.getCurrentTime());},250);}}}});}
var youtubeApi=document.createElement('script');youtubeApi.src='https://www.youtube.com/iframe_api';document.head.appendChild(youtubeApi);
<%}else{%>
videoElement=document.getElementById('learningVideo');if(videoElement)videoElement.addEventListener('timeupdate',function(){checkPlaybackTime(videoElement.currentTime);});
<%}%>
</script>
<%!String json(String s){return s==null?"null":"\""+s.replace("\\","\\\\").replace("\"","\\\"").replace("\n"," ").replace("\r"," ")+"\"";}%>
<jsp:include page="/views/common/footer.jsp" />
