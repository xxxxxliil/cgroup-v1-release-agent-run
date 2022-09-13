# cgroup-v1-release-agent-run
滥用 cgroup v1 notify_on_release 机制运行特定程序的 PoC
## 简单的介绍
目前是一非常啰嗦且混乱的脚本，尚不支持在容器里运行，如果只是为了在特权容器开洞建议看[这里](https://tldrsec.com/blog/container-security/)
### 使用
chmod 0755 后 sudo 跑下，然后祈祷它可以正确工作
### todo list
注：这个列表可能只会在 rust 实现，且不太可能会同步到 shell 脚本上
* [ ] 尽可能不依赖环境提供的命令
* [ ] 在容器里正确工作
* [ ] 友好的 cli
* [ ] 尝试通过滥用此机制作为 supervisor
* [ ] 滥用成功后伪装进程名字，就像 kingroot 那样（看起来像是 `[kworker/u%d:%d]`）
* [ ] 滥用成功启动后提供一个类似 telnetd 的接口执行 shell
* [ ] 用 rust 重写
### 一些废话
* 仅限 cgroup v1 哦，提前对那些“我有一个大胆的想法”的家伙们说一下
> ~~嘛，类似的 notify agent 机制也可以被滥用~~
* 这个 PoC 不应当作为一个 service supervision 使用！
> ~~当然，想做的话没人拦哦~~
* 题外话：还好 kingroot 没有在它不提供任何更新之前发现她，否则 kingroot 带有 kworker 名字的 daemon 就真的能以假乱真了
> ~~一键 root 在这玩意被发现并且验证为可滥用之后就没了，呜呜呜~~
* 留个问题：kingroot 和 360root 在 2021 年还提供服务吗？我的手机需要它（假设有空的话我看看能不能搞一个 360root/kingroot 转 SuperSU 或者其他 SU 的东西）
> ~~哪位酷友在用厕纸打的 360root 换 SuperSU 草稿还没打完啊？蚂蚁竞走不止十年啦！~~
## 历史故事
xxxxxliil@github 于 2021-05-06 09:17 时参考包括但不限于[这个](https://blog.nody.cc/posts/container-breakouts-part2)还有[这个](https://blog.trailofbits.com/2019/07/19/understanding-docker-container-escapes)终于成功在学校运行 Windows 的电脑里用 VirtualBox 运行的 Arch 手动触发 cgroup v1 的 notify_on_release 机制，随后再一次写了这个 PoC</br>
更：stat(1) 说这个人在 2021-05-06 10:13:19 初步完成</br>
stat: 最近更改：2021-05-06 10:13:19
