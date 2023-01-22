FROM node:19.4.0 as builder

COPY . .

RUN npm ci
RUN npm run build

FROM nginx:1.21.6

COPY --from=builder ./build /usr/share/nginx/html
