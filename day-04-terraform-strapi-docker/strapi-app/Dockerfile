FROM node:20-bullseye

WORKDIR /app

COPY package*.json ./

RUN npm install --production

COPY . .

RUN npm run build

EXPOSE 1337

ENV NODE_ENV=production

CMD ["npm", "run", "start"]

