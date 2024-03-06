FROM node:alpine

WORKDIR /app

COPY package.json package-lock.json ./

RUN npm install --ignore-scripts

COPY bin public routes app.js ./

USER node

RUN npm start

EXPOSE 3000