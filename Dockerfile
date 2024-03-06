FROM node:alpine

WORKDIR /app

COPY package.json package-lock.json ./

RUN npm install --ignore-scripts

COPY bin ./
COPY public ./
COPY routes ./
COPY app.js  ./

USER node

RUN npm start

EXPOSE 3000