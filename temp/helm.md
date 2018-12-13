## 集群管理数据库设计

```sql
-- DROP TABLE IF EXISTS `k8s_cluster`;
CREATE TABLE `k8s_cluster` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '行ID(主键)',
  `cluster_no` varchar(60) COLLATE utf8_bin NOT NULL COMMENT '集群编号',
  `cluster_name` varchar(60) COLLATE utf8_bin NOT NULL COMMENT '集群名称',
  `master_ip` varchar(16) COLLATE utf8_bin NOT NULL COMMENT 'master ip地址',
  `order_no` smallint(6) DEFAULT NULL COMMENT '排列序号',
  `status` tinyint(4) NOT NULL DEFAULT '1' COMMENT '状态(0=未生效 1=启用 2=作废)',
  `creator` varchar(20) COLLATE utf8_bin NOT NULL COMMENT '建档人',
  `create_time` datetime NOT NULL COMMENT '建档时间',
  `modifier` varchar(20) COLLATE utf8_bin DEFAULT NULL COMMENT '修改人',
  `modify_time` datetime DEFAULT NULL COMMENT '修改时间',
  `remarks` varchar(100) COLLATE utf8_bin DEFAULT NULL COMMENT '备注',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '记录更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_k8s_cluster_cluster_no` (`cluster_no`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='k8s集群';

-- DROP TABLE IF EXISTS `k8s_namespace`;
CREATE TABLE `k8s_namespace` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '行ID(主键)',
  `namespace_no` varchar(60) COLLATE utf8_bin NOT NULL COMMENT '命名空间编号',
  `namespace_name` varchar(60) COLLATE utf8_bin NOT NULL COMMENT '命名空间名称',
  `cluster_no` varchar(60) COLLATE utf8_bin NOT NULL COMMENT '所属集群编号',
  `env_no` varchar(10) COLLATE utf8_bin NOT NULL COMMENT '所属环境',
  `order_no` smallint(6) DEFAULT NULL COMMENT '排列序号',
  `status` tinyint(4) NOT NULL DEFAULT '1' COMMENT '状态(0=未生效 1=启用 2=作废)',
  `creator` varchar(20) COLLATE utf8_bin NOT NULL COMMENT '建档人',
  `create_time` datetime NOT NULL COMMENT '建档时间',
  `modifier` varchar(20) COLLATE utf8_bin DEFAULT NULL COMMENT '修改人',
  `modify_time` datetime DEFAULT NULL COMMENT '修改时间',
  `remarks` varchar(100) COLLATE utf8_bin DEFAULT NULL COMMENT '备注',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '记录更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_k8s_namespace_namespace_no` (`namespace_no`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='k8s集群命名空间';

-- DROP TABLE IF EXISTS `k8s_node`;
CREATE TABLE `k8s_node` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '行ID(主键)',
  `node_no` varchar(60) COLLATE utf8_bin NOT NULL COMMENT '节点编号(ip 地址)',
  `node_name` varchar(60) COLLATE utf8_bin NOT NULL COMMENT '节点名称',
  `node_classify` varchar(20) COLLATE utf8_bin NOT NULL COMMENT '节点分类',
  `cluster_no` varchar(60) COLLATE utf8_bin NOT NULL COMMENT '所属集群编号',
  `env_no` varchar(10) COLLATE utf8_bin NOT NULL COMMENT '所属环境',
  `region` varchar(60) COLLATE utf8_bin NOT NULL COMMENT '所属区域',
  `owner` varchar(20) COLLATE utf8_bin NOT NULL COMMENT '所有者',
  `order_no` smallint(6) DEFAULT NULL COMMENT '排列序号',
  `status` tinyint(4) NOT NULL DEFAULT '1' COMMENT '状态(0=未生效 1=启用 2=作废)',
  `creator` varchar(20) COLLATE utf8_bin NOT NULL COMMENT '建档人',
  `create_time` datetime NOT NULL COMMENT '建档时间',
  `modifier` varchar(20) COLLATE utf8_bin DEFAULT NULL COMMENT '修改人',
  `modify_time` datetime DEFAULT NULL COMMENT '修改时间',
  `remarks` varchar(100) COLLATE utf8_bin DEFAULT NULL COMMENT '备注',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '记录更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_k8s_node_node_no` (`node_no`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='k8s集群节点';

-- DROP TABLE IF EXISTS `k8s_node_label`;
CREATE TABLE `k8s_node_label` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '行ID(主键)',
  `node_no` varchar(60) COLLATE utf8_bin NOT NULL COMMENT '节点编号(ip 地址)',
  `label_key` varchar(60) COLLATE utf8_bin NOT NULL COMMENT '节点标签 key 值',
  `label_value` varchar(60) COLLATE utf8_bin NOT NULL COMMENT '节点标签 value 值',
  `order_no` smallint(6) DEFAULT NULL COMMENT '排列序号',
  `status` tinyint(4) NOT NULL DEFAULT '1' COMMENT '状态(0=未生效 1=启用 2=作废)',
  `creator` varchar(20) COLLATE utf8_bin NOT NULL COMMENT '建档人',
  `create_time` datetime NOT NULL COMMENT '建档时间',
  `modifier` varchar(20) COLLATE utf8_bin DEFAULT NULL COMMENT '修改人',
  `modify_time` datetime DEFAULT NULL COMMENT '修改时间',
  `remarks` varchar(100) COLLATE utf8_bin DEFAULT NULL COMMENT '备注',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '记录更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_k8s_node_label` (`node_no`, `label_key`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='k8s集群节点标签';
```
