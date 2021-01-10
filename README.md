# Reolink_camera_scripts
### A collection of scripts used for Reolink cameras and BlueIris

**[capture.sh](capture.sh)** - A shell script used to get a still image from Reolink IP camera.
Usage examples:

 - get a single image
 
`./capture.sh -a [camera_ip] -P [camera_port] -u [camera_user] -p [camera_password]`
- running continuously getting images at certain interval of time (in seconds)

`./capture.sh -a [camera_ip] -P [camera_port] -u [camera_user] -p [camera_password] -i [time_interval]`
- show help

`./capture.sh -h`
