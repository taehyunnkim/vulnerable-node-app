FROM node:alpine

WORKDIR /app/backend

COPY package.json package-lock.json ./

RUN npm install --ignore-scripts

COPY --chown=root:root --chmod=644 bin public routes app.js ./

RUN npm start

EXPOSE 3000