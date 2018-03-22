# discourse-furaffinity-onebox
Onebox plugin to support displaying FA submissions.

## Installation
* Add the plugin's repository URL to the end of the Discourse container's `app.xml` file (in `/var/discourse/containers/app.xml`). For example:
```
hooks:
  after_code:
    - exec:
        cd: $home/plugins
        cmd:
          - mkdir -p plugins
          - git clone https://github.com/discourse/docker_manager.git
          - git clone https://github.com/astruyk/discourse-furaffinity-onebox.git
```
* Rebuild the webpage
```
cd /var/discourse
./launcher rebuild app
```

That's it!
