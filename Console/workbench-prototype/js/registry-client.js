(function () {
    const DEFAULT_PACK_ID = 'agentharness.pack.pls-reference';

    const capabilityPackSnapshot = {
        identity: {
            packId: 'agentharness.pack.pls-reference',
            displayName: 'PLS Capability Pack',
            shortName: 'PLS Reference Pack',
            version: '0.1.0'
        },
        status: {
            lifecycle: 'evaluable',
            releaseReadiness: 'blocked',
            distributionReadiness: 'blocked'
        },
        summary: {
            description: 'Reference capability pack derived from the PLS project. Demonstrates AgentHarness capability registry seam.',
            authority: 'AgentHarness',
            consumer: 'pi-xanthil Host'
        },
        readiness: {
            evaluationStatus: 'warning',
            blockingReason: 'KnowledgeBase and MemoryBase integration pending',
            lastCheckedAt: '2026-07-24T00:00:00Z'
        },
        dependencies: {
            bases: [
                { base: 'DataBase', state: 'ready', note: 'PLS 表结构与指标证据已就绪' },
                { base: 'OntoBase', state: 'ready', note: 'PLS 维度语义与规则已就绪' },
                { base: 'KnowledgeBase', state: 'pending', note: '行业参考资料待集成' },
                { base: 'MemoryBase', state: 'pending', note: '用户反馈回路待集成' }
            ]
        },
        hostConsumer: {
            hostId: 'pi-xanthil',
            hostName: 'pi-xanthil Host',
            installState: 'simulated',
            usageState: 'simulated',
            feedbackState: 'not_connected',
            adapterState: 'simulated'
        },
        provenance: {
            sourceKind: 'reference_pack',
            sourceRefs: [
                { label: 'PRD', path: 'docs/prd-agentharness-four-bases-one-console-buildout.md', note: 'Product requirements' },
                { label: 'Discussion', path: 'docs/pi-xanthil-capability-pack-discussion.md', note: 'Capability pack design discussion' },
                { label: 'Prototype', path: 'Console/workbench-prototype/index.html', note: 'Frontend prototype' }
            ],
            dataBoundary: 'demo_only'
        }
    };

    function readMode() {
        const params = new URLSearchParams(window.location.search);
        return {
            mode: params.get('registryMode') || 'api',
            packId: params.get('packId') || DEFAULT_PACK_ID
        };
    }

    function validateShape(pack) {
        const missing = [];
        if (!pack || typeof pack !== 'object') return ['Pack is not an object'];
        if (!pack.identity || typeof pack.identity !== 'object') {
            missing.push('identity');
        } else {
            if (typeof pack.identity.packId !== 'string' || !pack.identity.packId) missing.push('identity.packId');
            if (typeof pack.identity.displayName !== 'string' || !pack.identity.displayName) missing.push('identity.displayName');
            if (typeof pack.identity.shortName !== 'string' || !pack.identity.shortName) missing.push('identity.shortName');
        }
        if (!pack.status || typeof pack.status !== 'object') {
            missing.push('status');
        } else {
            if (typeof pack.status.lifecycle !== 'string') missing.push('status.lifecycle');
        }
        if (!pack.readiness || typeof pack.readiness !== 'object') {
            missing.push('readiness');
        } else {
            if (typeof pack.readiness.evaluationStatus !== 'string') missing.push('readiness.evaluationStatus');
        }
        if (!pack.dependencies || typeof pack.dependencies !== 'object' || !Array.isArray(pack.dependencies.bases)) {
            missing.push('dependencies.bases');
        }
        if (!pack.hostConsumer || typeof pack.hostConsumer !== 'object') {
            missing.push('hostConsumer');
        }
        if (!pack.provenance || typeof pack.provenance !== 'object') {
            missing.push('provenance');
        } else {
            if (typeof pack.provenance.sourceKind !== 'string') missing.push('provenance.sourceKind');
            if (typeof pack.provenance.dataBoundary !== 'string') missing.push('provenance.dataBoundary');
        }
        return missing;
    }

    async function fetchFromApi(packId) {
        const url = '/api/capability-packs/' + encodeURIComponent(packId);
        let response;
        try {
            response = await fetch(url);
        } catch (err) {
            return {
                ok: false,
                reason: 'network_error',
                message: '无法连接 Capability Registry HTTP API。页面已 fail closed，未展示任何能力包，没有使用 snapshot 兜底。'
            };
        }

        if (!response.ok) {
            const is404 = response.status === 404;
            return {
                ok: false,
                reason: is404 ? 'not_found' : 'http_error',
                message: is404
                    ? 'Capability Registry HTTP API 返回 404：未找到 packId ' + packId + '。页面已 fail closed，没有使用 snapshot 兜底。'
                    : 'Capability Registry HTTP API 返回 HTTP ' + response.status + '。页面已 fail closed，没有使用 snapshot 兜底。'
            };
        }

        let pack;
        try {
            pack = await response.json();
        } catch (err) {
            return {
                ok: false,
                reason: 'invalid_json',
                message: 'Capability Registry HTTP API 返回内容不是合法 JSON。页面已 fail closed，没有使用 snapshot 兜底。'
            };
        }

        if (pack && typeof pack === 'object' && typeof pack.error === 'string') {
            return {
                ok: false,
                reason: pack.error || 'api_error',
                message: 'Capability Registry HTTP API 返回错误：' + pack.error + '。页面已 fail closed，没有使用 snapshot 兜底。'
            };
        }

        const missingFields = validateShape(pack);
        if (missingFields.length > 0) {
            return {
                ok: false,
                reason: 'invalid_shape',
                message: 'Capability Registry HTTP API 返回数据缺少关键字段：' + missingFields.join(', ') + '。页面已 fail closed，没有使用 snapshot 兜底。'
            };
        }

        return { ok: true, pack: pack };
    }

    function getFromSnapshot(packId) {
        if (packId !== capabilityPackSnapshot.identity.packId) {
            return {
                ok: false,
                reason: 'not_found',
                message: 'Snapshot 模式未找到 packId: ' + packId + '。'
            };
        }
        return { ok: true, pack: capabilityPackSnapshot };
    }

    async function getCapabilityPack() {
        const request = readMode();

        if (request.mode === 'snapshot') {
            return getFromSnapshot(request.packId);
        }

        return fetchFromApi(request.packId);
    }

    window.RegistryClient = {
        getCapabilityPack: getCapabilityPack,
        isSnapshotMode: function () {
            return readMode().mode === 'snapshot';
        }
    };
}());
