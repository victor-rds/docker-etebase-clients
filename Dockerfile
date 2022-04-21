
FROM node:18.0.0-alpine as build

ARG CLIENT_VERSION=master
ARG CLIENT_REPO="https://github.com/etesync/etesync-web.git"

ARG NOTES_VERSION=master
ARG NOTES_REPO="https://github.com/etesync/etesync-notes.git"

ARG REACT_APP_DEFAULT_API_PATH="https://api.etebase.com/partner/etesync/"

RUN apk add --no-cache git; \
    yarn global add expo-cli;\
    export NODE_OPTIONS=--openssl-legacy-provider; \
    git clone --depth 1 --branch "${CLIENT_VERSION}" "${CLIENT_REPO}" etesync-web; \
    git clone --depth 1 --branch "${NOTES_VERSION}" "${NOTES_REPO}" etesync-notes; \
    cd /etesync-web; \
    yarn; \
    yarn build; \
    cd /etesync-notes; \
    yarn; \
    expo build:web

FROM nginx:1.21.6-alpine

COPY --from=build /etesync-web/build /usr/share/nginx/html/client
COPY --from=build /etesync-notes/web-build /usr/share/nginx/html/notes
COPY context/nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80



