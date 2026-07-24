document.addEventListener('DOMContentLoaded', () => {
    const registryState = document.getElementById('registry-state');
    const registryMessage = document.getElementById('registry-message');
    const workspacePack = document.getElementById('workspace-pack');
    const workspacePackMeta = document.getElementById('workspace-pack-meta');
    const workspaceBlocking = document.getElementById('workspace-blocking');
    const workspaceBlockingMeta = document.getElementById('workspace-blocking-meta');
    const countChip = document.getElementById('capability-count');
    const tableBody = document.getElementById('capability-table-body');
    const selectedTitle = document.getElementById('selected-title');
    const selectedSummary = document.getElementById('selected-summary');
    const selectedLifecycle = document.getElementById('selected-lifecycle');
    const packIdentity = document.getElementById('pack-identity');
    const baseStatus = document.getElementById('base-status');
    const evalStatus = document.getElementById('eval-status');
    const releaseStatus = document.getElementById('release-status');
    const hostStatus = document.getElementById('host-status');
    const dataBoundary = document.getElementById('data-boundary');
    const sourceKind = document.getElementById('source-kind');
    const checklistCount = document.getElementById('checklist-count');
    const lifecycleList = document.getElementById('lifecycle-list');
    const sourceList = document.getElementById('source-list');
    const actionTitle = document.getElementById('action-title');
    const actionState = document.getElementById('action-state');
    const feedback = document.getElementById('action-feedback');
    const runEval = document.getElementById('run-eval');
    const prepareRelease = document.getElementById('prepare-release');
    const distribute = document.getElementById('distribute');
    const openAudit = document.getElementById('open-audit');
    const auditToggle = document.getElementById('audit-toggle');
    const hostTitle = document.getElementById('host-title');
    const hostBadge = document.getElementById('host-badge');
    const hostStack = document.getElementById('host-stack');
    const dependencyStack = document.getElementById('dependency-stack');

    const lifecycleLabels = {
        draft: ['草稿', 'badge-gray'],
        evaluable: ['可评估', 'badge-blue'],
        released: ['已发布', 'badge-green'],
        deprecated: ['已废弃', 'badge-gray']
    };

    const tableHeadMarkup = `
        <div class="table-row table-head" role="row">
            <span>名称</span>
            <span>生命周期</span>
            <span>就绪度</span>
            <span>Host</span>
        </div>
    `;

    const readinessLabels = {
        not_run: '未运行评估',
        warning: '评估有提醒',
        passed: '评估通过',
        failed: '评估失败'
    };

    const stateLabels = {
        ready: '已就绪',
        pending: '待接入',
        blocked: '受阻',
        not_applicable: '不适用',
        simulated: '模拟',
        not_connected: '未连接',
        installable: '可安装',
        installed: '已安装',
        usable: '可使用',
        receiving: '接收中',
        connected: '已连接'
    };

    function setBadgeClass(element, className) {
        element.className = 'badge ' + className;
    }

    function labelFor(map, value) {
        return map[value] || value;
    }

    function statusClass(state) {
        if (state === 'ready' || state === 'passed' || state === 'released' || state === 'connected') {
            return 'ready';
        }

        if (state === 'blocked' || state === 'failed' || state === 'not_connected') {
            return 'blocked';
        }

        return 'pending';
    }

    function badgeClass(state) {
        if (state === 'ready' || state === 'passed' || state === 'released') {
            return 'badge-green';
        }

        if (state === 'pending' || state === 'warning' || state === 'simulated') {
            return 'badge-amber';
        }

        return 'badge-gray';
    }

    function escapeHtml(value) {
        return String(value)
            .replace(/&/g, '&amp;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;')
            .replace(/"/g, '&quot;')
            .replace(/'/g, '&#039;');
    }

    function renderFailClosed(result) {
        registryState.textContent = result.reason === 'not_found' ? '未找到能力包' : 'Registry 读取失败';
        setBadgeClass(registryState, 'badge-amber');
        registryMessage.textContent = result.message;
        workspacePack.textContent = '未加载';
        workspacePackMeta.textContent = 'Capability Registry fail closed；未展示任何能力包，没有使用 snapshot 兜底。';
        workspaceBlocking.textContent = 'Registry 不可用';
        workspaceBlockingMeta.textContent = '操作保持禁用；需恢复 HTTP API 连接后才能查看能力包。';
        countChip.textContent = '0 个 registry 项';
        tableBody.innerHTML = tableHeadMarkup + '<div class="registry-empty" role="row">未展示任何能力包；没有使用 snapshot 兜底。</div>';
        selectedTitle.textContent = 'Capability Registry 未加载';
        selectedSummary.textContent = '页面已 fail closed。请检查 HTTP API 连接状态或 packId。';
        selectedLifecycle.textContent = '不可用';
        setBadgeClass(selectedLifecycle, 'badge-amber');
        packIdentity.textContent = '无 registry pack identity';
        baseStatus.textContent = '未读取';
        evalStatus.textContent = '未读取';
        releaseStatus.textContent = '未读取';
        hostStatus.textContent = '未读取';
        dataBoundary.textContent = '未读取';
        sourceKind.textContent = '未读取';
        checklistCount.textContent = '0 / 0 已完成';
        lifecycleList.innerHTML = '<li class="blocked">registry 未加载，停止展示能力详情</li>';
        sourceList.innerHTML = '<li>无来源引用可展示</li>';
        actionTitle.textContent = 'Registry 未加载';
        actionState.textContent = '已禁用';
        setBadgeClass(actionState, 'badge-amber');
        feedback.className = 'feedback-box pending';
        feedback.textContent = '真实动作未接入；registry 错误状态下所有操作保持禁用。';
        [runEval, prepareRelease, distribute, openAudit].forEach(function (button) {
            button.disabled = true;
        });
        hostTitle.textContent = 'Host consumer 未加载';
        hostBadge.textContent = 'fail closed';
        setBadgeClass(hostBadge, 'badge-amber');
        hostStack.innerHTML = '<div class="host-step blocked"><strong>停止</strong><span>未读取 registry，不能推断 Host 状态。</span></div>';
        dependencyStack.innerHTML = '<div class="dependency-item blocked"><strong>未读取</strong><span>未从 Readiness ReadModel 获得 Base-level observations。</span></div>';
    }

    function renderPack(pack, isSnapshotMode) {
        const lifecycle = lifecycleLabels[pack.status.lifecycle] || [pack.status.lifecycle, 'badge-gray'];
        const readyBases = pack.dependencies.bases.filter(function (base) { return base.state === 'ready'; });

        if (isSnapshotMode) {
            registryState.textContent = 'Snapshot 开发模式';
            setBadgeClass(registryState, 'badge-amber');
            registryMessage.textContent = '当前为 snapshot 开发/离线模式，数据来源为静态 snapshot，非 HTTP API。';
        } else {
            registryState.textContent = 'Registry 正常';
            setBadgeClass(registryState, 'badge-green');
            registryMessage.textContent = '来自 Capability Registry HTTP API：' + pack.identity.packId;
        }

        workspacePack.textContent = pack.identity.displayName;
        workspacePackMeta.textContent = pack.identity.shortName + ' · version ' + pack.identity.version + ' · authority: ' + pack.summary.authority + ' · consumer: ' + pack.summary.consumer;
        workspaceBlocking.textContent = pack.readiness.blockingReason;
        workspaceBlockingMeta.textContent = 'releaseReadiness=' + pack.status.releaseReadiness + ' · distributionReadiness=' + pack.status.distributionReadiness;
        countChip.textContent = '1 个 registry 项';
        tableBody.innerHTML = tableHeadMarkup +
            '<button class="table-row selected" type="button" data-pack-id="' + escapeHtml(pack.identity.packId) + '" role="row" aria-pressed="true">' +
                '<span>' +
                    '<strong>' + escapeHtml(pack.identity.displayName) + '</strong>' +
                    '<small>' + escapeHtml(pack.identity.shortName) + ' · ' + escapeHtml(pack.identity.packId) + '</small>' +
                '</span>' +
                '<span class="badge ' + lifecycle[1] + '">' + lifecycle[0] + '</span>' +
                '<span>' + escapeHtml(labelFor(readinessLabels, pack.readiness.evaluationStatus)) + '</span>' +
                '<span>' + escapeHtml(pack.hostConsumer.hostName) + ' · ' + escapeHtml(labelFor(stateLabels, pack.hostConsumer.adapterState)) + '</span>' +
            '</button>';
        selectedTitle.textContent = pack.identity.displayName;
        selectedSummary.textContent = pack.summary.description;
        selectedLifecycle.textContent = lifecycle[0];
        setBadgeClass(selectedLifecycle, lifecycle[1]);
        packIdentity.textContent = pack.identity.packId + ' · ' + pack.identity.shortName + ' · ' + pack.identity.version;
        baseStatus.textContent = readyBases.length + ' / ' + pack.dependencies.bases.length + ' 个 Base-level 依赖已就绪（Readiness ReadModel）';
        evalStatus.textContent = labelFor(readinessLabels, pack.readiness.evaluationStatus) + ' · ' + pack.readiness.lastCheckedAt;
        releaseStatus.textContent = '发布 ' + labelFor(stateLabels, pack.status.releaseReadiness) + ' · 分发 ' + labelFor(stateLabels, pack.status.distributionReadiness);
        hostStatus.textContent = pack.hostConsumer.hostName + ' adapter ' + labelFor(stateLabels, pack.hostConsumer.adapterState);
        dataBoundary.textContent = pack.provenance.dataBoundary;
        sourceKind.textContent = pack.provenance.sourceKind;
        checklistCount.textContent = readyBases.length + ' / ' + pack.dependencies.bases.length + ' 已就绪';
        lifecycleList.innerHTML = pack.dependencies.bases
            .map(function (base) { return '<li class="' + statusClass(base.state) + '">' + escapeHtml(base.base) + '：' + escapeHtml(labelFor(stateLabels, base.state)) + ' · <em>Readiness ReadModel observation</em> · ' + escapeHtml(base.note) + '</li>'; })
            .join('');
        sourceList.innerHTML = pack.provenance.sourceRefs
            .map(function (ref) { return '<li><strong>' + escapeHtml(ref.label) + '</strong><span>' + escapeHtml(ref.path) + ' · ' + escapeHtml(ref.note) + '</span></li>'; })
            .join('');
        actionTitle.textContent = pack.identity.displayName;
        actionState.textContent = '模拟 / 未接入';
        setBadgeClass(actionState, 'badge-amber');
        feedback.className = 'feedback-box';
        feedback.textContent = '操作区仅用于演示状态反馈；不会调用真实 install、release、evaluation、distribution、license 或 audit 后端。';
        runEval.disabled = false;
        prepareRelease.disabled = true;
        distribute.disabled = true;
        openAudit.disabled = false;
        hostTitle.textContent = pack.hostConsumer.hostName;
        hostBadge.textContent = labelFor(stateLabels, pack.hostConsumer.adapterState);
        setBadgeClass(hostBadge, badgeClass(pack.hostConsumer.adapterState));
        hostStack.innerHTML = [
            ['安装', pack.hostConsumer.installState, '真实安装未接入，仅允许模拟说明'],
            ['使用', pack.hostConsumer.usageState, 'Host 使用入口未形成生产闭环'],
            ['反馈', pack.hostConsumer.feedbackState, '等待 Host adapter 回传真实使用信号'],
            ['Adapter', pack.hostConsumer.adapterState, '保持模拟，不修改 pi-xanthil']
        ].map(function (item) { return '<div class="host-step ' + statusClass(item[1]) + '"><strong>' + item[0] + '</strong><span>' + escapeHtml(labelFor(stateLabels, item[1])) + ' · ' + escapeHtml(item[2]) + '</span></div>'; }).join('');
        dependencyStack.innerHTML = pack.dependencies.bases
            .map(function (base) { return '<div class="dependency-item ' + statusClass(base.state) + '"><strong>' + escapeHtml(base.base) + '</strong><span>' + escapeHtml(labelFor(stateLabels, base.state)) + ' · Readiness ReadModel observation · ' + escapeHtml(base.note) + '</span></div>'; })
            .join('');
    }

    async function init() {
        const result = await window.RegistryClient.getCapabilityPack();
        const isSnapshotMode = window.RegistryClient.isSnapshotMode();

        if (!result.ok) {
            renderFailClosed(result);
        } else {
            renderPack(result.pack, isSnapshotMode);
        }
    }

    init();

    runEval.addEventListener('click', function () {
        feedback.className = 'feedback-box pending';
        feedback.textContent = '模拟评估：未调用真实 evaluation backend，仅在前端演示 feedback 状态。';
        runEval.disabled = true;
        window.setTimeout(function () {
            feedback.className = 'feedback-box success';
            feedback.textContent = '模拟评估完成：registry 数据未被写入，release 仍保持未接入。';
            actionState.textContent = '模拟已刷新';
            setBadgeClass(actionState, 'badge-amber');
            runEval.disabled = false;
        }, 650);
    });

    prepareRelease.addEventListener('click', function () {
        feedback.className = 'feedback-box pending';
        feedback.textContent = '准备发布未接入：本任务不实现 release、artifact、license 或 audit 写入。';
    });

    distribute.addEventListener('click', function () {
        feedback.className = 'feedback-box pending';
        feedback.textContent = '分发未接入：pi-xanthil Host adapter 仍为模拟状态。';
    });

    openAudit.addEventListener('click', function () {
        document.querySelectorAll('.audit-extra').forEach(function (item) {
            item.hidden = false;
        });
        auditToggle.textContent = '收起详情';
        feedback.className = 'feedback-box success';
        feedback.textContent = '审计仅打开演示证据；没有写入真实 audit event。';
    });

    auditToggle.addEventListener('click', function () {
        const extras = document.querySelectorAll('.audit-extra');
        const shouldShow = Array.from(extras).some(function (item) { return item.hidden; });
        extras.forEach(function (item) {
            item.hidden = !shouldShow;
        });
        auditToggle.textContent = shouldShow ? '收起详情' : '显示详情';
    });
});
