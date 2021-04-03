; ModuleID = 'module'
source_filename = "module"

%literal = type { double, double }

@format_number = private unnamed_addr constant [5 x i8] c"%lf\0A\00", align 1
@format_true = private unnamed_addr constant [6 x i8] c"true\0A\00", align 1
@format_false = private unnamed_addr constant [7 x i8] c"false\0A\00", align 1
@format_string = private unnamed_addr constant [6 x i8] c"\22%s\22\0A\00", align 1
@format_function = private unnamed_addr constant [17 x i8] c"function object\0A\00", align 1
@format_undef = private unnamed_addr constant [11 x i8] c"undefined\0A\00", align 1
@format_error = private unnamed_addr constant [13 x i8] c"error: \22%s\22\0A\00", align 1

declare i8* @malloc(i32)

declare i64 @printf(i8*, ...)

declare i8* @strcpy(i8*, i8*)

declare i32 @strlen(i8*)

declare i8* @strcat(i8*, i8*)

declare void @exit(i32)

define void @display(%literal* %0) {
entry:
  %1 = getelementptr inbounds %literal, %literal* %0, i32 0, i32 0
  %2 = getelementptr inbounds %literal, %literal* %0, i32 0, i32 1
  %3 = load double, double* %1
  %4 = load double, double* %2
  %5 = fcmp oeq double %3, 2.000000e+00
  br i1 %5, label %display_boolean, label %tmp

tmp:                                              ; preds = %entry
  %6 = fcmp oeq double %3, 3.000000e+00
  br i1 %6, label %display_string, label %tmp1

tmp1:                                             ; preds = %tmp
  %7 = fcmp oeq double %3, 4.000000e+00
  br i1 %7, label %display_function, label %tmp2

tmp2:                                             ; preds = %tmp1
  %8 = fcmp oeq double %3, 5.000000e+00
  br i1 %8, label %display_undefined, label %display_number

display_number:                                   ; preds = %tmp2
  %9 = call i64 (i8*, ...) @printf(i8* getelementptr inbounds ([5 x i8], [5 x i8]* @format_number, i32 0, i32 0), double %4)
  br label %end

display_boolean:                                  ; preds = %entry
  %10 = fcmp oeq double %4, 1.000000e+00
  br i1 %10, label %print_true, label %print_false

print_true:                                       ; preds = %display_boolean
  %11 = call i64 (i8*, ...) @printf(i8* getelementptr inbounds ([6 x i8], [6 x i8]* @format_true, i32 0, i32 0))
  br label %end

print_false:                                      ; preds = %display_boolean
  %12 = call i64 (i8*, ...) @printf(i8* getelementptr inbounds ([7 x i8], [7 x i8]* @format_false, i32 0, i32 0))
  br label %end

display_string:                                   ; preds = %tmp
  %13 = bitcast double %4 to i64
  %14 = call i64 (i8*, ...) @printf(i8* getelementptr inbounds ([6 x i8], [6 x i8]* @format_string, i32 0, i32 0), i64 %13)
  br label %end

display_function:                                 ; preds = %tmp1
  %15 = call i64 (i8*, ...) @printf(i8* getelementptr inbounds ([17 x i8], [17 x i8]* @format_function, i32 0, i32 0))
  br label %end

display_undefined:                                ; preds = %tmp2
  %16 = call i64 (i8*, ...) @printf(i8* getelementptr inbounds ([11 x i8], [11 x i8]* @format_undef, i32 0, i32 0))
  br label %end

end:                                              ; preds = %display_undefined, %display_function, %display_string, %print_false, %print_true, %display_number
  ret void
}

define void @error(i8* %0) {
entry:
  %1 = call i64 (i8*, ...) @printf(i8* getelementptr inbounds ([13 x i8], [13 x i8]* @format_error, i32 0, i32 0), i8* %0)
  call void @exit(i32 1)
  ret void
}

define i8* @strconcat(i8* %0, i8* %1) {
entry:
  %2 = call i32 @strlen(i8* %0)
  %3 = call i32 @strlen(i8* %1)
  %4 = add i32 %2, %3
  %5 = add i32 %4, 1
  %6 = call i8* @malloc(i32 %5)
  %7 = call i8* @strcpy(i8* %6, i8* %0)
  %8 = call i8* @strcat(i8* %6, i8* %1)
  ret i8* %6
}

define i32 @main() {
entry:
  %env = call i8* @malloc(i32 8)
  %0 = bitcast i8* %env to %literal**
  %1 = call i8* @malloc(i32 16)
  %2 = bitcast i8* %1 to %literal*
  %3 = getelementptr inbounds %literal, %literal* %2, i32 0, i32 0
  %4 = getelementptr inbounds %literal, %literal* %2, i32 0, i32 1
  store double 5.000000e+00, double* %3
  store double 0.000000e+00, double* %4
  %env1 = call i8* @malloc(i32 8)
  %5 = bitcast i8* %env1 to %literal**
  %6 = bitcast %literal** %5 to %literal***
  store %literal** %0, %literal*** %6
  %7 = call i8* @malloc(i32 16)
  %8 = bitcast i8* %7 to %literal*
  %9 = getelementptr inbounds %literal, %literal* %8, i32 0, i32 0
  %10 = getelementptr inbounds %literal, %literal* %8, i32 0, i32 1
  store double 5.000000e+00, double* %9
  store double 0.000000e+00, double* %10
  %11 = call i8* @malloc(i32 16)
  %12 = bitcast i8* %11 to %literal*
  %13 = getelementptr inbounds %literal, %literal* %12, i32 0, i32 0
  %14 = getelementptr inbounds %literal, %literal* %12, i32 0, i32 1
  store double 2.000000e+00, double* %13
  store double 0.000000e+00, double* %14
  %15 = getelementptr inbounds %literal, %literal* %12, i32 0, i32 1
  %16 = load double, double* %15
  %17 = fptosi double %16 to i1
  br i1 %17, label %if.true, label %if.false

if.true:                                          ; preds = %entry
  %env2 = call i8* @malloc(i32 8)
  %18 = bitcast i8* %env2 to %literal**
  %19 = bitcast %literal** %18 to %literal***
  store %literal** %5, %literal*** %19
  %20 = call i8* @malloc(i32 16)
  %21 = bitcast i8* %20 to %literal*
  %22 = getelementptr inbounds %literal, %literal* %21, i32 0, i32 0
  %23 = getelementptr inbounds %literal, %literal* %21, i32 0, i32 1
  store double 1.000000e+00, double* %22
  store double 1.000000e+00, double* %23
  call void @display(%literal* %21)
  br label %if.end

if.false:                                         ; preds = %entry
  %env3 = call i8* @malloc(i32 8)
  %24 = bitcast i8* %env3 to %literal**
  %25 = bitcast %literal** %24 to %literal***
  store %literal** %5, %literal*** %25
  %26 = call i8* @malloc(i32 16)
  %27 = bitcast i8* %26 to %literal*
  %28 = getelementptr inbounds %literal, %literal* %27, i32 0, i32 0
  %29 = getelementptr inbounds %literal, %literal* %27, i32 0, i32 1
  store double 2.000000e+00, double* %28
  store double 1.000000e+00, double* %29
  %30 = getelementptr inbounds %literal, %literal* %27, i32 0, i32 1
  %31 = load double, double* %30
  %32 = fptosi double %31 to i1
  br i1 %32, label %if.true4, label %if.false5

if.end:                                           ; preds = %if.end6, %if.true
  %33 = phi %literal* [ %8, %if.true ], [ %46, %if.end6 ]
  call void @display(%literal* %33)
  ret i32 0

if.true4:                                         ; preds = %if.false
  %env7 = call i8* @malloc(i32 8)
  %34 = bitcast i8* %env7 to %literal**
  %35 = bitcast %literal** %34 to %literal***
  store %literal** %24, %literal*** %35
  %36 = call i8* @malloc(i32 16)
  %37 = bitcast i8* %36 to %literal*
  %38 = getelementptr inbounds %literal, %literal* %37, i32 0, i32 0
  %39 = getelementptr inbounds %literal, %literal* %37, i32 0, i32 1
  store double 1.000000e+00, double* %38
  store double 2.000000e+00, double* %39
  call void @display(%literal* %37)
  br label %if.end6

if.false5:                                        ; preds = %if.false
  %env8 = call i8* @malloc(i32 8)
  %40 = bitcast i8* %env8 to %literal**
  %41 = bitcast %literal** %40 to %literal***
  store %literal** %24, %literal*** %41
  %42 = call i8* @malloc(i32 16)
  %43 = bitcast i8* %42 to %literal*
  %44 = getelementptr inbounds %literal, %literal* %43, i32 0, i32 0
  %45 = getelementptr inbounds %literal, %literal* %43, i32 0, i32 1
  store double 1.000000e+00, double* %44
  store double 3.000000e+00, double* %45
  call void @display(%literal* %43)
  br label %if.end6

if.end6:                                          ; preds = %if.false5, %if.true4
  %46 = phi %literal* [ %8, %if.true4 ], [ %8, %if.false5 ]
  br label %if.end
}

