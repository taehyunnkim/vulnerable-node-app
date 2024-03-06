FROM node:alpine

RUN mkdir -p /app && chown -R node:node /app

WORKDIR /app

USER node

COPY package.json package-lock.json ./

RUN npm install --ignore-scripts

COPY --chown=node:node --chmod=400 bin public routes app.js ./

RUN npm start

EXPOSE 3000