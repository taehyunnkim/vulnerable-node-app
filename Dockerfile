FROM node:alpine

RUN mkdir -p /usr/src/node-app && chown -R node:node /usr/src/node-app

WORKDIR /usr/src/node-app

COPY package.json package-lock.json ./

USER node

RUN npm install --ignore-scripts

COPY --chown=root:root --chmod=644 bin public routes app.js ./

RUN npm start

EXPOSE 3000