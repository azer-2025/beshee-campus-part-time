package org.example.springboot.DTO;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotNull;
import lombok.Data;
import org.example.springboot.entity.User;

@Data
@Schema(description = "后台创建用户及附属档案DTO")
public class AdminUserCreateDTO {
    @Valid
    @NotNull(message = "用户信息不能为空")
    @Schema(description = "用户账号信息")
    private User user;

    @Schema(description = "学生档案信息，仅学生角色时使用")
    private StudentProfileDTO studentProfile;
}
