 # Systemd 脚本工具

 生成Systemd配置

- 默认值 user:group => deploy:deploy
```bash
 $ bin/systemd puma sidekiq
```
- 设定 user / group
```bash
 $ bin/systemd puma sidekiq user:deploy group:deploy
```