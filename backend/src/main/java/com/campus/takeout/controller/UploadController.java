package com.campus.takeout.controller;

import com.campus.takeout.common.BusinessException;
import com.campus.takeout.common.Result;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.Arrays;
import java.util.List;
import java.util.UUID;

/**
 * 统一文件上传接口。校验类型与大小，使用 UUID 文件名防覆盖与路径穿越，
 * 文件落地到 uploads/业务模块/年/月/，数据库只存返回的相对路径。
 */
@RestController
@RequestMapping("/api/upload")
public class UploadController {

    @Value("${file.upload-dir}")
    private String uploadDir;

    private static final List<String> ALLOW = Arrays.asList("jpg", "jpeg", "png", "webp", "gif");
    private static final long MAX_SIZE = 5 * 1024 * 1024;

    @PostMapping
    public Result<String> upload(@RequestParam("file") MultipartFile file,
                                 @RequestParam(value = "module", defaultValue = "common") String module) {
        if (file == null || file.isEmpty()) {
            throw new BusinessException("请选择要上传的文件");
        }
        if (file.getSize() > MAX_SIZE) {
            throw new BusinessException("图片大小不能超过 5MB");
        }
        String original = file.getOriginalFilename();
        String ext = "";
        if (original != null && original.contains(".")) {
            ext = original.substring(original.lastIndexOf(".") + 1).toLowerCase();
        }
        if (!ALLOW.contains(ext)) {
            throw new BusinessException("仅支持 jpg/jpeg/png/webp/gif 格式图片");
        }
        // 业务模块名仅允许字母，避免路径穿越
        String safeModule = module.replaceAll("[^a-zA-Z]", "");
        if (safeModule.isEmpty()) {
            safeModule = "common";
        }
        String datePath = LocalDate.now().format(DateTimeFormatter.ofPattern("yyyy/MM"));
        String relativeDir = uploadDir + "/" + safeModule + "/" + datePath;
        File dir = new File(relativeDir);
        if (!dir.exists() && !dir.mkdirs()) {
            throw new BusinessException("上传目录创建失败");
        }
        String fileName = UUID.randomUUID().toString().replace("-", "") + "." + ext;
        File dest = new File(dir, fileName);
        try {
            file.transferTo(dest.getAbsoluteFile());
        } catch (IOException e) {
            throw new BusinessException("文件保存失败：" + e.getMessage());
        }
        // 返回相对路径（含文件名），数据库保存此值，前端拼接后端地址即可访问
        return Result.success(relativeDir + "/" + fileName);
    }
}
