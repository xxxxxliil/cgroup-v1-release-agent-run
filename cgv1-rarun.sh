#!/bin/sh



#cgv1ra run: 基于 cgroup v1 的 notify_on_release 机制运行特定程序的 PoC
# xxxxxliil@github 于 2021-05-06 09:17 时成功在学校运行 Windows 的电脑里用 VirtualBox 运行的 Arch 手动触发 cgroup v1 的 notify_on_release 机制，随后写了这个 PoC
#更：stat(1) 说这个人在 2021-05-06 10:13:19 初步完成
#stat: 最近更改：2021-05-06 10:13:19

#不可能在 cgroup v2 存在，提前对那些“我有一个大胆的想法”的家伙们说一下
#这个 PoC 不应当作为一个 service supervision 使用！当然，没有人拦着你这么做
#题外话：还好 kingroot 没有在它不提供任何更新之前发现她，否则 kingroot 带有 kworker 名字的 daemon 就真的能以假乱真了
#留个问题：kingroot 和 360root 在 2021 年还提供服务吗？我的手机需要它（假设有空的话我看看能不能搞一个 360root/kingroot 转 SuperSU 或者其他 SU 的东西）



CGV1_RARUN_BASE_DIR='/dev'
CGV1_RARUN_NAME='nosubsys-cgv1'
CGV1_RARUN_MOUNT_PATH="${CGV1_RARUN_BASE_DIR}/${CGV1_RARUN_NAME}"
CGV1_RARUN_MOUNT_OPTIONS="nodev,noexec,nosuid,relatime"
CGV1_RARUN_RUN_NODE_NAME="${CGV1_RARUN_NAME}-run"

MAKE_RUN_PROG_PATH="true"
RUN_PROG_PATH="${CGV1_RARUN_BASE_DIR}/${CGV1_RARUN_RUN_NODE_NAME}.sh"



echo "run ${RUN_PROG_PATH}"
if [ "${MAKE_RUN_PROG_PATH}" = 'true' ]; then
  cat > "${RUN_PROG_PATH}" <<-EOF
#!/bin/sh

exec >/dev/cgv1-rarun.sh.out
exec 2>/dev/cgv1-rarun.sh.err

echo "Welcome to using base on cgroup v1's PoC: cgroup v1 release run!!!"
echo "Welcome to using base on cgroup v1's PoC: cgroup v1 release run!!!(With stderr)" >&2

ps -wwef

echo "args: \${@}"
echo "env: "
set

sleep 9999
EOF
  chmod 0755 "${RUN_PROG_PATH}"
fi

[ ! -d "${CGV1_RARUN_MOUNT_PATH}" ] && mkdir "${CGV1_RARUN_MOUNT_PATH}"
mount -o name="${CGV1_RARUN_NAME}",none,"${CGV1_RARUN_MOUNT_OPTIONS}" -t cgroup "${CGV1_RARUN_NAME}" "${CGV1_RARUN_MOUNT_PATH}"

#我不知道 Linux Kernel 会不会一直执行它，反正我不认为用这玩意当服务管理器是什么好主意，相反，这很坏
#^: 指会不会有执行时间限制
echo "${RUN_PROG_PATH}" >"${CGV1_RARUN_MOUNT_PATH}/release_agent"


echo 1 >"${CGV1_RARUN_MOUNT_PATH}/notify_on_release"
mkdir -p "${CGV1_RARUN_MOUNT_PATH}/${CGV1_RARUN_RUN_NODE_NAME}"

#写入一个转瞬即逝的进程就好
#enjoy
sh -c "echo \$\$ > ${CGV1_RARUN_MOUNT_PATH}/${CGV1_RARUN_RUN_NODE_NAME}/cgroup.procs"
echo "Welcome to using base on cgroup v1's PoC: meta cgroup run!!!"

rmdir ${CGV1_RARUN_MOUNT_PATH}/${CGV1_RARUN_RUN_NODE_NAME} && umount "${CGV1_RARUN_MOUNT_PATH}"
