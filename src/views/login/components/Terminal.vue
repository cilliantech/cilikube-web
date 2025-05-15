<template>
  <div class="mac-terminal-window">
    <div class="mac-terminal-header">
      <div class="mac-buttons">
        <span class="close"></span>
        <span class="minimize"></span>
        <span class="maximize"></span>
      </div>
      <span class="mac-title">CILIKUBE</span> </div>

    <div ref="terminalRef" class="terminal-content">
      <div v-for="(line, index) in terminalLines" :key="index" class="terminal-line">
        <pre>{{ line.typedText }}<span v-if="line.isTyping && index === terminalLines.length - 1" class="cursor"></span></pre>
      </div>
      <div v-if="isSimulationComplete" class="terminal-line">
        <pre><span class="cursor"></span></pre>
      </div>
       <div v-if="!isSimulationComplete && terminalLines.length === 0" class="terminal-line">
           <pre><span class="cursor"></span></pre>
       </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, nextTick } from 'vue';

const terminalLines = ref([]);
const terminalRef = ref(null); // 用于获取终端 DOM 元素的引用
const isSimulationComplete = ref(false); // 标记整个模拟是否完成

// 定义命令和输出
const commands = [
  { command: 'user@cilikube:~$ echo "hello world!"', output: 'hello world!' },
  {
    command: 'user@cilikube:~$ what is life ?',
    output: '生活的意义，也许一时难以看清，但能和一群志同道合的人，全情投入的做一些喜欢和热爱的事，这本身就是最有意义的活法！',
  },
  {
    command: 'user@cilikube:~$ 加入CILIKUBE社区',
    output: 'Star! 添加开发者微信cillianops，进入社区群聊！',
  },
];

const typeSpeed = 50; // 每个字符的打字速度（毫秒）

// 滚动终端到底部
const scrollToBottom = () => {
  const terminalElement = terminalRef.value;
  if (terminalElement) {
    nextTick(() => {
      terminalElement.scrollTop = terminalElement.scrollHeight;
    });
  }
};

// 模拟打字效果
const typeText = async (line) => {
  line.typedText = '';
  line.isTyping = true;
  for (const char of line.text) {
    line.typedText += char;
    scrollToBottom();
    await new Promise(resolve => setTimeout(resolve, typeSpeed));
  }
  line.isTyping = false;
  scrollToBottom();
};

// 启动终端模拟
const startTerminalSimulation = async () => {
  isSimulationComplete.value = false;

  for (let i = 0; i < commands.length; i++) {
    const cmd = commands[i];
    const commandLine = { type: 'command', text: cmd.command, typedText: '', isTyping: false };
    terminalLines.value.push(commandLine);
    scrollToBottom();
    await typeText(commandLine);
    await new Promise(resolve => setTimeout(resolve, 500));

    const outputLine = { type: 'output', text: cmd.output, typedText: '', isTyping: false };
    terminalLines.value.push(outputLine);
    scrollToBottom();
    await typeText(outputLine);

    if (i < commands.length - 1) {
       await new Promise(resolve => setTimeout(resolve, 1000));
    }
  }
  isSimulationComplete.value = true;
  scrollToBottom();
};

onMounted(() => {
  startTerminalSimulation();
});
</script>

<style scoped>
/* 外层容器，模拟 macOS 窗口 */
.mac-terminal-window {
  width: 100%;
  max-width: 800px; /* 控制最大宽度 */
  border-radius: 8px; /* 圆角 */
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.5); /* 更真实的阴影 */
  overflow: hidden; /* 隐藏超出圆角的内容 */
  background-color: #1e1e1e; /* 终端背景色 */
  font-family: 'Courier New', monospace;
  color: #00ff00; /* 终端绿色文字 */
  box-sizing: border-box;
}

/* 窗口标题栏 */
.mac-terminal-header {
  height: 24px; /* 标题栏高度 */
  background-color: #333; /* 标题栏背景色 */
  display: flex;
  align-items: center;
  padding: 0 8px;
  position: relative; /* 用于标题居中 */
  flex-shrink: 0; /* 防止在flex布局中缩小 */
  -webkit-app-region: drag; /* 使标题栏可拖动（在某些特定环境下有效） */
}

.mac-buttons {
  display: flex;
  align-items: center;
  z-index: 1; /* 确保按钮在标题上方 */
   -webkit-app-region: no-drag; /* 防止按钮区域被拖动 */
}

.mac-buttons span {
  display: inline-block;
  width: 12px;
  height: 12px;
  border-radius: 50%;
  margin-right: 6px;
  cursor: pointer; /* 按钮增加鼠标样式 */
}

.mac-buttons .close { background-color: #ff605c; } /* 红色 */
.mac-buttons .minimize { background-color: #ffbd44; } /* 黄色 */
.mac-buttons .maximize { background-color: #00bF50; } /* 绿色 */

.mac-title {
  position: absolute; /* 绝对定位居中 */
  left: 0;
  right: 0;
  text-align: center;
  color: #eedfdf; /* 标题颜色 */
  font-size: 13px;
  line-height: 24px; /* 垂直居中 */
  pointer-events: none; /* 防止文字阻碍鼠标事件 */
}


/* 终端内容区域 */
.terminal-content {
  padding: 10px 20px 20px; /* 调整内边距，顶部留给标题栏 */
  min-height: 300px; /* 最小高度 */
  max-height: 500px; /* 最大高度 */
  overflow-y: auto; /* 允许垂直滚动 */
  box-sizing: border-box;
  word-break: break-word; /* 确保长文本能在边界断开 */
}

.terminal-line {
  /* display: flex; /* 如果需要对齐光标 */
  white-space: pre-wrap; /* 保留空白符，允许换行 */
  word-break: break-word; /* 确保长文本能在边界断开 */
  line-height: 1.5; /* 调整行高 */
}

/* pre 标签是块级元素，默认就会换行。移除之前的 inline 设置 */
.terminal-line pre { /* 精确指定只影响 .terminal-line 下的 pre */
    margin: 0;
    padding: 0;
    /* display: block; <--- pre 默认就是 block */
    word-break: break-word;
    white-space: pre-wrap; /* 确保换行 */
}


.cursor {
  display: inline-block; /* 使光标可见，并在文本流中占据位置 */
  width: 2px; /* 竖线宽度 */
  height: 1em; /* 高度与字体大小一致 */
  background-color: #00ff00; /* 绿色 */
  vertical-align: bottom; /* 与文本底对齐 */
  margin-left: 2px;
  animation: blink 1s step-end infinite;
}

@keyframes blink {
  50% {
    opacity: 0;
  }
}

/* 隐藏滚动条，可选 */
.terminal-content::-webkit-scrollbar {
  width: 8px; /* 滚动条宽度 */
}
.terminal-content::-webkit-scrollbar-track {
  background: #333; /* 轨道背景 */
}
.terminal-content::-webkit-scrollbar-thumb {
  background: #555; /* 滑块颜色 */
  border-radius: 4px;
}
.terminal-content::-webkit-scrollbar-thumb:hover {
  background: #777;
}

/* For Firefox */
.terminal-content {
  scrollbar-width: thin; /* "auto" or "thin" */
  scrollbar-color: #555 #333; /* thumb and track color */
}
</style>