* MP4 TO MP4 (MEDIUM)

  ```
  ffmpeg -i input.mp4 -b 1000000 output.mp4
  ```

  

* M2TS TO MP4

  ```
  ffmpeg -i input.m2ts -vcodec libx264 -crf 20 -acodec ac3 -vf "yadif" output.mp4
  ```

  

* MP4 TO WEBM (HIGH)

  ```
  ffmpeg -i input.mp4 -aq 5 -ac 2 -qmax 25 -threads 2 output.webm
  ffmpeg -i input.mp4 -c:v libvpx-vp9 -crf 30 -b:v 0 -b:a 128k -c:a libopus output.webm
  ```

  

* MP4 TO WEBM (MEDIUM)

  ```
  ffmpeg -i input.mp4 -aq 5 -ac 2 -qmax 35 -threads 2 output.webm
  ```

  

* MP4 TO OGV (HIGH)

  ```
  ffmpeg -i input.mp4 -vcodec libtheora -acodec libvorbis -q:v 6 -q:a 5 output.ogv
  ```

  

* MP4 TO OGV (MEDIUM)

  ```
  ffmpeg -i input.mp4 -vcodec libtheora -acodec libvorbis -q:v 2 -q:a 4 output.ogv
  ```

* extract audio only

  ```bash
  ffmpeg -i input.mp4 -acodec copy -vn out.aac
  //acodec :指定音频编码器，copy只拷贝，不做编码
  //vn:v代表视频，n代表no,无视频的意思
  ```
  
* extract vedio only

  ```bash
  ffmpeg -i input.mp4 -vcodec copy -an out.mp4
  //vcodec:指定视频编码器，copy只拷贝，不做编码
  //an:a代表音频,n代表no，无音频的意思。
  ```
  
* combine vedio and audio

  ```bash
  ffmpeg -i out.mp4 -i out.aac -vcodec copy -acodec copy new.mp4
  //-vcodec copy ：视频只拷贝，不编解码
  //-acodec copy : 音频只拷贝，不编解码
  //new.mp4 ：新生成的文件，文件的长度由两个输入文件的最长的决定
  ```
  
* cut out vedio

  ```bash
  ffmpeg -ss 00:00:00 -t 00:00:18 -i ori.mp4 -vcodec copy -acodec copy new.mp4
  // -ss start time
  // -t duration
  // --to end time
  ```
  
  