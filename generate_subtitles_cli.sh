#!/bin/bash

# 获取脚本所在的目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 用法提示
if [ "$#" -ne 1 ]; then
  echo "用法: $0 <video_file.mp4>"
  exit 1
fi

VIDEO_FILE="$1"
BASENAME=$(basename "$VIDEO_FILE" | sed 's/\.[^.]*$//')
AUDIO_FILE="${BASENAME}.wav"
OUTPUT_PREFIX="${BASENAME}_sub"
MODEL_PATH="${SCRIPT_DIR}/models/ggml-small.en.bin"  # 相对脚本路径定位模型
WHISPER_CLI="${SCRIPT_DIR}/build/bin/whisper-cli"   # 相对脚本路径定位可执行文件

# 提取音频
echo "🎧 正在提取音频..."
ffmpeg -y -i "$VIDEO_FILE" -ar 16000 -ac 1 -c:a pcm_s16le "$AUDIO_FILE"

# 使用 whisper-cli 生成 SRT 字幕
echo "🧠 正在生成字幕..."
"$WHISPER_CLI" \
  -m "$MODEL_PATH" \
  -f "$AUDIO_FILE" \
  -of "$OUTPUT_PREFIX" \
  -osrt

# 删除临时 wav 文件
echo "🧹 清理临时文件..."
rm -f "$AUDIO_FILE"

# 完成提示
echo "✅ 字幕已生成: ${OUTPUT_PREFIX}.srt"

