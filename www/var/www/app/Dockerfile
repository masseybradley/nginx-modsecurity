FROM node:14-alpine as build
WORKDIR /workspace/source
COPY app .
RUN yarn build

FROM nginx:1.9.8
COPY --from=build /workspace/source/build /usr/share/nginx/html
