# using node base image to be able to build our source code into
# static content
# naming the stage of this build stage to be 'buildphase'
# (this allow us to reference to it later)
FROM node:16-alpine as buildphase

# setting up relative path in temporary container
WORKDIR '/app'

# copying ./package.json into /app
COPY package.json .

# installing dependencies required to run npm run build
RUN npm install

# copying all local source code to container's FS
# so that build CMD has everything it needs
COPY . .

# running npm run build to generate a static build folder
# with all static files required to serve inbound browser traffic
CMD [ "npm", "run", "build" ]
RUN npm run build

# when we specify a second FROM within a Dockerfile
# docker assumes termination of the previous phase
# we don't need to specify a stage here as we don't
# use this in a later stage - just looks tidy
FROM nginx as runPhase

# to developers, this is only informative specifying that,
# a mapping should be built with port 80 from the container
# and not another one
EXPOSE 80

# in this new temporary container, there's no /app/build
# this was done in previous stage buildPhase and therefore
# it is in the FS of that temporary container
# we can access the previous stage's FS by using --from=stage
COPY --from=buildphase /app/build /usr/share/nginx/html

# we don't need to specify a CMD instruction to run the nginx
# production server, nginx default command will start the server
# by default