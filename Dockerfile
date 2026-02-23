FROM node:18-alpine

RUN apk add --no-cache git python3 py3-pip make g++ build-base

ENV N8N_PORT=7860
ENV N8N_PROTOCOL=https

RUN npm install -g n8n

WORKDIR /data

EXPOSE 7860

CMD ["n8n", "start"]
