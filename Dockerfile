# Name the node stage "builder"
FROM node:18.16.1 AS builder
# Set working directory
ARG region=prod
WORKDIR /app
# Copy all files from current directory to working dir in image
COPY package*.json ./
RUN npm install
COPY . .
# install node modules and build assets
# RUN yarn install --registry=https://registry.yarnpkg.com/ && yarn build --mode $region

EXPOSE 8080
ENTRYPOINT ["npm", "run", "start"]
