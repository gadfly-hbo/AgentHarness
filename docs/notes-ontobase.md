# OntoBase Domain Notes

## Owner

Kilo Code。

## 负责

- `OntoBase/**` 内的业务对象、属性语义、关系、指标、规则、动作、语义映射和 source binding。
- 维护平台标签、PLS 维度等业务语义的权威校准记录。

## 不负责

- 创建或修改 DataBase table、view、migration 或事实行。
- 把 DataBase schema 当作 OntoBase 的宿主或内部实现。

## 强制验证

- 对象身份、关系方向、映射原因和 DataSource Binding 可追溯。
- ReadModel 与一等业务实体明确区分。
- DataBase 绑定只记录外部入口，不复制事实数据。

## 跨域出口

OntoBase 通过 contract 向 Console、产品和其他库发布稳定对象身份、语义维度、指标口径、规则和解释链路。
