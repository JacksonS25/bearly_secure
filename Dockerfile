FROM golang:1.27.0-alpine AS build
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
EXPOSE 3030 4040
RUN CGO_ENABLED=0 go build -trimpath -o /out/server ./cmd/server && CGO_ENABLED=0 go build -trimpath -o /out/attackerlab ./cmd/attackerlab


FROM alpine:3.22
RUN apk add --no-cache ca-certificates && addgroup -S bearly && adduser -S -G bearly bearly
WORKDIR /app
COPY --from=build /out/server ./bearly-secure
COPY --from=build /out/attackerlab ./bearly-attacker-lab
COPY ./attacker-lab ./attacker-lab
COPY ./web ./web
COPY ./data/uploads/mystery-shack-tax-exemption.pdf ./data/uploads/mystery-shack-tax-exemption.pdf
RUN chown -R bearly:bearly /app/data
USER bearly
CMD ["./bearly-secure"]