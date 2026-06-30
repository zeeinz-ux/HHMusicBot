FROM node:24-slim

RUN apt-get update && apt-get install -y python3 && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY package*.json ./
RUN npm install --ignore-scripts

COPY . .

RUN npm run postinstall

ENV NODE_ENV=production

EXPOSE 10000

CMD ["node", "index.js"]
