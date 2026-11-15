/*
 Navicat Premium Data Transfer

 Source Server         : mysql
 Source Server Type    : MySQL
 Source Server Version : 80041 (8.0.41)
 Source Host           : localhost:3306
 Source Schema         : campus_recruitment

 Target Server Type    : MySQL
 Target Server Version : 80041 (8.0.41)
 File Encoding         : 65001

 Date: 02/01/2026 10:29:43
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for application
-- ----------------------------
DROP TABLE IF EXISTS `application`;
CREATE TABLE `application`  (
                                `id` bigint NOT NULL AUTO_INCREMENT COMMENT '投递ID',
                                `student_id` bigint NOT NULL COMMENT '学生ID',
                                `position_id` bigint NOT NULL COMMENT '职位ID',
                                `resume_id` bigint NOT NULL COMMENT '简历ID',
                                `status` int NOT NULL DEFAULT 0 COMMENT '投递状态(0待查看/1已查看/2通过筛选/3面试邀请/4不合适/5已录用)',
                                `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
                                `update_time` datetime NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
                                PRIMARY KEY (`id`) USING BTREE,
                                INDEX `idx_student_id`(`student_id` ASC) USING BTREE,
                                INDEX `idx_position_id`(`position_id` ASC) USING BTREE,
                                INDEX `idx_status`(`status` ASC) USING BTREE,
                                INDEX `idx_resume_id`(`resume_id` ASC) USING BTREE,
                                CONSTRAINT `fk_application_position_id` FOREIGN KEY (`position_id`) REFERENCES `position` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
                                CONSTRAINT `fk_application_student_id` FOREIGN KEY (`student_id`) REFERENCES `student` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 8 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '投递记录表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of application
-- ----------------------------

-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- ----------------------------
-- Table structure for company
-- ----------------------------
DROP TABLE IF EXISTS `company`;
CREATE TABLE `company`  (
                            `id` bigint NOT NULL AUTO_INCREMENT COMMENT '企业ID',
                            `user_id` bigint NOT NULL COMMENT '用户ID',
                            `company_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '企业名称',
                            `industry` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '所属行业',
                            `company_size` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '企业规模',
                            `company_address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '企业地址',
                            `company_logo` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '企业Logo',
                            `company_intro` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '企业简介',
                            `verified` tinyint(1) NOT NULL DEFAULT 0 COMMENT '是否认证(0未认证/1已认证)',
                            `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
                            `update_time` datetime NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
                            PRIMARY KEY (`id`) USING BTREE,
                            UNIQUE INDEX `uk_user_id`(`user_id` ASC) USING BTREE,
                            CONSTRAINT `fk_company_user_id` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 6 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '企业信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of company
-- ----------------------------

-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- ----------------------------
-- Table structure for interview
-- ----------------------------
DROP TABLE IF EXISTS `interview`;
CREATE TABLE `interview`  (
                              `id` bigint NOT NULL AUTO_INCREMENT COMMENT '面试ID',
                              `application_id` bigint NOT NULL COMMENT '投递ID',
                              `interview_time` datetime NOT NULL COMMENT '面试时间',
                              `interview_address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '面试地点',
                              `interview_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '面试类型(现场/视频/电话)',
                              `interview_note` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '面试备注',
                              `interview_status` int NOT NULL DEFAULT 0 COMMENT '面试状态(0待确认/1已确认/2已完成/3已取消)',
                              `interview_result` int NOT NULL DEFAULT 0 COMMENT '面试结果(0未知/1通过/2未通过)',
                              `feedback` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '面试反馈',
                              `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
                              `update_time` datetime NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
                              PRIMARY KEY (`id`) USING BTREE,
                              INDEX `idx_application_id`(`application_id` ASC) USING BTREE,
                              INDEX `idx_interview_time`(`interview_time` ASC) USING BTREE,
                              INDEX `idx_interview_status`(`interview_status` ASC) USING BTREE,
                              CONSTRAINT `fk_interview_application_id` FOREIGN KEY (`application_id`) REFERENCES `application` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '面试表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of interview
-- ----------------------------

-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- ----------------------------
-- Table structure for message
-- ----------------------------
DROP TABLE IF EXISTS `message`;
CREATE TABLE `message`  (
                            `id` bigint NOT NULL AUTO_INCREMENT COMMENT '消息ID',
                            `sender_id` bigint NULL DEFAULT NULL COMMENT '发送者ID',
                            `receiver_id` bigint NOT NULL COMMENT '接收者ID',
                            `message_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '消息类型',
                            `title` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '消息标题',
                            `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '消息内容',
                            `is_read` tinyint(1) NOT NULL DEFAULT 0 COMMENT '是否已读(0未读/1已读)',
                            `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
                            `update_time` datetime NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
                            PRIMARY KEY (`id`) USING BTREE,
                            INDEX `idx_receiver_id`(`receiver_id` ASC) USING BTREE,
                            INDEX `idx_is_read`(`is_read` ASC) USING BTREE,
                            INDEX `idx_sender_id`(`sender_id` ASC) USING BTREE,
                            CONSTRAINT `fk_message_receiver_id` FOREIGN KEY (`receiver_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
                            CONSTRAINT `fk_message_sender_id` FOREIGN KEY (`sender_id`) REFERENCES `user` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 25 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '消息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of message
-- ----------------------------

-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- ----------------------------
-- Table structure for position
-- ----------------------------
DROP TABLE IF EXISTS `position`;
CREATE TABLE `position`  (
                             `id` bigint NOT NULL AUTO_INCREMENT COMMENT '职位ID',
                             `company_id` bigint NOT NULL COMMENT '企业ID',
                             `position_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '职位名称',
                             `position_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '职位类型',
                             `position_category` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '职位类别',
                             `salary_min` int NULL DEFAULT NULL COMMENT '最低薪资',
                             `salary_max` int NULL DEFAULT NULL COMMENT '最高薪资',
                             `education_requirement` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '学历要求',
                             `experience_requirement` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '经验要求',
                             `work_address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '工作地点',
                             `position_description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '职位描述',
                             `position_requirement` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '职位要求',
                             `position_count` int NULL DEFAULT NULL COMMENT '招聘人数',
                             `status` int NOT NULL DEFAULT 2 COMMENT '职位状态(0下线/1上线/2审核中)',
                             `deadline` date NULL DEFAULT NULL COMMENT '截止日期',
                             `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
                             `update_time` datetime NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
                             PRIMARY KEY (`id`) USING BTREE,
                             INDEX `idx_company_id`(`company_id` ASC) USING BTREE,
                             INDEX `idx_position_name`(`position_name` ASC) USING BTREE,
                             INDEX `idx_status`(`status` ASC) USING BTREE,
                             CONSTRAINT `fk_position_company_id` FOREIGN KEY (`company_id`) REFERENCES `company` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 11 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '职位表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of position
-- ----------------------------

-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- ----------------------------
-- Table structure for resume
-- ----------------------------
DROP TABLE IF EXISTS `resume`;
CREATE TABLE `resume`  (
                           `id` bigint NOT NULL AUTO_INCREMENT COMMENT '简历ID',
                           `student_id` bigint NOT NULL COMMENT '学生ID',
                           `resume_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '简历名称',
                           `resume_content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '简历内容(JSON格式)',
                           `resume_file` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '简历文件路径',
                           `pdf_path` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'PDF文件路径',
                           `is_default` tinyint(1) NOT NULL DEFAULT 0 COMMENT '是否默认简历(0否/1是)',
                           `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
                           `update_time` datetime NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
                           PRIMARY KEY (`id`) USING BTREE,
                           INDEX `idx_student_id`(`student_id` ASC) USING BTREE,
                           CONSTRAINT `fk_resume_student_id` FOREIGN KEY (`student_id`) REFERENCES `student` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 12 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '简历表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of resume
-- ----------------------------

-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- ----------------------------
-- Table structure for student
-- ----------------------------
DROP TABLE IF EXISTS `student`;
CREATE TABLE `student`  (
                            `id` bigint NOT NULL AUTO_INCREMENT COMMENT '学生ID',
                            `user_id` bigint NOT NULL COMMENT '用户ID',
                            `student_no` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '学号',
                            `college` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '学院',
                            `major` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '专业',
                            `education` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '学历',
                            `graduation_year` int NULL DEFAULT NULL COMMENT '毕业年份',
                            `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
                            `update_time` datetime NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
                            PRIMARY KEY (`id`) USING BTREE,
                            UNIQUE INDEX `uk_user_id`(`user_id` ASC) USING BTREE,
                            UNIQUE INDEX `uk_student_no`(`student_no` ASC) USING BTREE,
                            CONSTRAINT `fk_student_user_id` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '学生信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of student
-- ----------------------------

-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- ----------------------------
-- Table structure for user
-- ----------------------------
DROP TABLE IF EXISTS `user`;
CREATE TABLE `user`  (
                         `id` bigint NOT NULL AUTO_INCREMENT COMMENT '用户ID',
                         `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '用户名',
                         `password` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '密码',
                         `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '真实姓名',
                         `sex` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '性别',
                         `avatar` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '头像',
                         `email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '邮箱',
                         `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '手机号',
                         `role_code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '角色编码(STUDENT/COMPANY/ADMIN)',
                         `status` int NOT NULL DEFAULT 1 COMMENT '账号状态(0禁用/1启用)',
                         `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
                         `update_time` datetime NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
                         PRIMARY KEY (`id`) USING BTREE,
                         UNIQUE INDEX `uk_username`(`username` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 16 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of user
-- ----------------------------

-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


SET FOREIGN_KEY_CHECKS = 1;
