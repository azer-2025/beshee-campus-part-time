package org.example.springboot.DTO;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

@Data
@Schema(description = "学生档案信息DTO")
public class StudentProfileDTO {
    @Schema(description = "学生档案ID")
    private Long id;

    @Schema(description = "学号")
    private String studentNo;

    @Schema(description = "学院")
    private String college;

    @Schema(description = "专业")
    private String major;

    @Schema(description = "学历")
    private String education;

    @Schema(description = "毕业年份")
    private Integer graduationYear;
}
