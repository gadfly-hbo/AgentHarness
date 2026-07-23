document.addEventListener('DOMContentLoaded', () => {
    const capabilityData = {
        pls: {
            title: 'PLS Capability Pack',
            summary: '用于管理 PLS 能力包（Capability Pack）评估、发布与 pi-xanthil 分发的静态原型。',
            lifecycle: '可评估',
            lifecycleClass: 'badge-blue',
            actionState: '待评估',
            actionClass: 'badge-amber',
            baseStatus: 'DataBase + OntoBase 已就绪',
            evalStatus: '上次评估通过但有提醒',
            releaseStatus: '准备发布受阻',
            hostStatus: 'pi-xanthil adapter 待确认',
            checklistCount: '3 / 4 已完成',
            checklist: [
                ['done', '来源证据已映射'],
                ['done', 'OntoBase 语义已挂接'],
                ['done', '已有演示评估结果'],
                ['blocked', '发布包尚未准备']
            ]
        },
        sql: {
            title: 'SQL Generator',
            summary: 'Tool Registry 候选能力，用于演示选择能力后详情区会变化。',
            lifecycle: '评估中',
            lifecycleClass: 'badge-amber',
            actionState: '评估中',
            actionClass: 'badge-amber',
            baseStatus: 'OntoBase 语义待复核',
            evalStatus: '验证运行中',
            releaseStatus: '暂不可发布',
            hostStatus: '无 pi-xanthil 安装目标',
            checklistCount: '2 / 4 已完成',
            checklist: [
                ['done', '工具候选已登记'],
                ['done', '评估任务已启动'],
                ['blocked', '策略复核未完成'],
                ['blocked', '发布包尚未准备']
            ]
        },
        doc: {
            title: 'Doc Searcher',
            summary: 'Knowledge 检索原型，在静态工作台中保留为草稿能力。',
            lifecycle: '草稿',
            lifecycleClass: 'badge-gray',
            actionState: '草稿态',
            actionClass: 'badge-gray',
            baseStatus: '仅有 KnowledgeBase 来源规划',
            evalStatus: '尚未评估',
            releaseStatus: '草稿态受阻',
            hostStatus: '无 Host 目标',
            checklistCount: '1 / 4 已完成',
            checklist: [
                ['done', '能力想法已记录'],
                ['blocked', '来源绑定未验证'],
                ['blocked', '缺少评估结果'],
                ['blocked', '发布包尚未准备']
            ]
        },
        architect: {
            title: 'Code Architect',
            summary: 'Memory 辅助 Skill 概念，在本演示中用于展示受阻操作状态。',
            lifecycle: '受阻',
            lifecycleClass: 'badge-gray',
            actionState: '安全审核中',
            actionClass: 'badge-amber',
            baseStatus: 'MemoryBase 治理待确认',
            evalStatus: '评估受阻',
            releaseStatus: '安全审核中',
            hostStatus: '不可分发',
            checklistCount: '1 / 4 已完成',
            checklist: [
                ['done', 'Skill 概念已记录'],
                ['blocked', '缺少安全复核'],
                ['blocked', '评估受阻'],
                ['blocked', '发布包尚未准备']
            ]
        }
    };

    const rows = document.querySelectorAll('[data-capability]');
    const title = document.getElementById('selected-title');
    const summary = document.getElementById('selected-summary');
    const lifecycle = document.getElementById('selected-lifecycle');
    const actionState = document.getElementById('action-state');
    const baseStatus = document.getElementById('base-status');
    const evalStatus = document.getElementById('eval-status');
    const releaseStatus = document.getElementById('release-status');
    const hostStatus = document.getElementById('host-status');
    const checklistCount = document.getElementById('checklist-count');
    const lifecycleList = document.getElementById('lifecycle-list');
    const feedback = document.getElementById('action-feedback');
    const runEval = document.getElementById('run-eval');
    const prepareRelease = document.getElementById('prepare-release');
    const distribute = document.getElementById('distribute');
    const openAudit = document.getElementById('open-audit');
    const auditToggle = document.getElementById('audit-toggle');

    function setBadgeClass(element, className) {
        element.className = `badge ${className}`;
    }

    function renderCapability(key) {
        const capability = capabilityData[key];
        title.textContent = capability.title;
        summary.textContent = capability.summary;
        lifecycle.textContent = capability.lifecycle;
        setBadgeClass(lifecycle, capability.lifecycleClass);
        actionState.textContent = capability.actionState;
        setBadgeClass(actionState, capability.actionClass);
        baseStatus.textContent = capability.baseStatus;
        evalStatus.textContent = capability.evalStatus;
        releaseStatus.textContent = capability.releaseStatus;
        hostStatus.textContent = capability.hostStatus;
        checklistCount.textContent = capability.checklistCount;
        lifecycleList.innerHTML = capability.checklist
            .map(([state, label]) => `<li class="${state}">${label}</li>`)
            .join('');

        const isPls = key === 'pls';
        runEval.disabled = !isPls;
        prepareRelease.disabled = true;
        distribute.disabled = true;
        feedback.className = 'feedback-box';
        feedback.textContent = isPls
            ? '可执行原型操作；不会调用真实后端。'
            : `${capability.title} 仅用于本静态原型中的选择演示。`;
    }

    rows.forEach(row => {
        row.addEventListener('click', () => {
            rows.forEach(candidate => {
                candidate.classList.remove('selected');
                candidate.setAttribute('aria-pressed', 'false');
            });
            row.classList.add('selected');
            row.setAttribute('aria-pressed', 'true');
            renderCapability(row.dataset.capability);
        });
    });

    runEval.addEventListener('click', () => {
        feedback.className = 'feedback-box pending';
        feedback.textContent = '评估进行中：正在以演示模式检查 DataBase 证据与 OntoBase 语义。';
        runEval.disabled = true;
        window.setTimeout(() => {
            feedback.className = 'feedback-box success';
            feedback.textContent = '评估成功：PLS Capability Pack 已满足准备发布条件。此状态仅为原型模拟。';
            actionState.textContent = '评估已刷新';
            setBadgeClass(actionState, 'badge-green');
            evalStatus.textContent = '当前评估成功';
            releaseStatus.textContent = '可准备发布';
            prepareRelease.disabled = false;
            runEval.disabled = false;
        }, 650);
    });

    prepareRelease.addEventListener('click', () => {
        feedback.className = 'feedback-box success';
        feedback.textContent = '发布准备完成：分发仍需确认 Host adapter 检查点。';
        actionState.textContent = '发布就绪';
        setBadgeClass(actionState, 'badge-green');
        releaseStatus.textContent = '发布包已准备';
        hostStatus.textContent = '可模拟 pi-xanthil 分发';
        distribute.disabled = false;
    });

    distribute.addEventListener('click', () => {
        feedback.className = 'feedback-box pending';
        feedback.textContent = '分发受阻：pi-xanthil Host 消费仍是模拟状态，未连接真实 Host adapter。';
        actionState.textContent = 'Host 受阻';
        setBadgeClass(actionState, 'badge-amber');
    });

    openAudit.addEventListener('click', () => {
        document.querySelectorAll('.audit-extra').forEach(item => {
            item.hidden = false;
        });
        auditToggle.textContent = '收起详情';
        feedback.className = 'feedback-box success';
        feedback.textContent = '审计已打开：下方显示紧凑的演示证据。';
    });

    auditToggle.addEventListener('click', () => {
        const extras = document.querySelectorAll('.audit-extra');
        const shouldShow = Array.from(extras).some(item => item.hidden);
        extras.forEach(item => {
            item.hidden = !shouldShow;
        });
        auditToggle.textContent = shouldShow ? '收起详情' : '显示详情';
    });
});
