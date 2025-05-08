# 使用最新 LTS 版本的 Node.js 作为构建基础镜像，并命名为 builder
FROM node:lts AS builder

# 设置工作目录为 /app
WORKDIR /app

# 复制 package.json 和 pnpm-lock.yaml（如果使用 pnpm，同时支持 npm）
COPY package.json pnpm-lock.yaml* ./

# 安装项目依赖
RUN npm install -g pnpm && \
    pnpm install --frozen-lockfile # 确保依赖版本一致

# 复制项目源代码到工作目录
COPY . .

# 运行构建命令
RUN pnpm build

# --- 生产环境镜像 ---
# 使用 Alpine 版本的 Nginx 作为基础镜像，以减小体积
FROM nginx:stable-alpine

# 从 builder 阶段复制构建产物到 Nginx 的默认静态资源目录
COPY --from=builder /app/dist /usr/share/nginx/html

# （可选）如果您有自定义的 Nginx 配置，取消注释并复制
# COPY ./nginx.conf /etc/nginx/conf.d/default.conf

# 暴露 80 端口，允许外部访问
EXPOSE 80

# 启动 Nginx 服务，并保持在前台运行
CMD ["nginx", "-g", "daemon off;"]
