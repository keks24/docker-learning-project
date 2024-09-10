FROM debian:bookworm-slim AS builder
    # cache busting: always install the latest packages
    ARG DEBIAN_FRONTEND="noninteractive"
    RUN apt-get update && \
        apt-get install -y \
            pandoc

    # make the image small, by always removing the package cache,
    # since "apt-get update" is always executed above.
    RUN rm --recursive --force "/var/lib/apt/lists/"

    WORKDIR "/source/"
    #COPY ./*.md /source/
    # temporarily mount "README.md" for generating "index.html"
    RUN --mount="type=bind",source="./README.md",target="/source/README.md" \
        pandoc -f markdown "README.md" > "index.html"

FROM httpd:alpine AS apache
    COPY --from="builder" "/source/index.html" "/usr/local/apache2/htdocs/"
    # document, which port should be exposed.
    # this does not open the port itself!
    EXPOSE 80/tcp

FROM nginx:alpine AS nginx
    COPY --from="builder" "/source/index.html" "/usr/share/nginx/html/"
    # document, which port should be exposed.
    # this does not open the port itself!
    EXPOSE 80/tcp
