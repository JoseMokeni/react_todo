# Nginx Reverse Proxy Setup for Minikube

This guide will help you set up a reverse proxy using Nginx to access a service running in Minikube.

## Prerequisites

- A Virtual Machine (VM) with Minikube installed.
- A service running in Minikube that you want to access from outside the VM.

## Steps

1. **Update your VM's package lists**

    ```bash
    sudo apt-get update
    ```

2. **Install Nginx**

    ```bash
    sudo apt-get install nginx
    ```

3. **Remove the default Nginx site (if it exists)**

    First, check if the default site exists:

    ```bash
    ls /etc/nginx/sites-enabled
    ```

    If you see a file named `default`, remove it:

    ```bash
    sudo rm /etc/nginx/sites-enabled/default
    ```

4. **Create a new Nginx configuration file**

    ```bash
    sudo nano /etc/nginx/sites-available/minikube-proxy
    ```

    Add the following content to the file, replacing `minikubeip` with the IP address of your Minikube VM and `nodeport` with the NodePort of your service:

    ```nginx
    server {
        listen 80;
        location / {
            proxy_pass http://minikubeip:nodeport;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        }
    }
    ```

5. **Enable the new site**

    ```bash
    sudo ln -s /etc/nginx/sites-available/minikube-proxy /etc/nginx/sites-enabled/
    ```

6. **Test the Nginx configuration**

    ```bash
    sudo nginx -t
    ```

    If the configuration test is successful, you'll see a message like this:

    ```
    nginx: configuration file /etc/nginx/nginx.conf test is successful
    ```

7. **Reload Nginx to apply the changes**

    ```bash
    sudo systemctl reload nginx
    ```

Now, you should be able to access your Minikube service by visiting the IP address of your VM in a web browser.