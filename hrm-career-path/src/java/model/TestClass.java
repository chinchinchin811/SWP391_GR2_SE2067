package model;

/** Lớp mentor hiện tại được phép quản lý bài kiểm tra. */
public record TestClass(int id, String name, Integer departmentId, String status) { }
