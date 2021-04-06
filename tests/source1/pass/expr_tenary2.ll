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
@0 = private unnamed_addr constant [18 x i8] c"boo type mismatch\00", align 1

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
  %env1 = call i8* @malloc(i32 16)
  %5 = bitcast i8* %env1 to %literal**
  %6 = bitcast %literal** %5 to %literal***
  store %literal** %0, %literal*** %6
  %7 = call i8* @malloc(i32 16)
  %8 = bitcast i8* %7 to %literal*
  %9 = getelementptr inbounds %literal, %literal* %8, i32 0, i32 0
  %10 = getelementptr inbounds %literal, %literal* %8, i32 0, i32 1
  store double 5.000000e+00, double* %9
  store double 0.000000e+00, double* %10
  %11 = getelementptr inbounds %literal*, %literal** %5, i32 1
  store %literal* %8, %literal** %11
  %12 = call i8* @malloc(i32 16)
  %13 = bitcast i8* %12 to %literal*
  %14 = getelementptr inbounds %literal, %literal* %13, i32 0, i32 0
  %15 = getelementptr inbounds %literal, %literal* %13, i32 0, i32 1
  store double 2.000000e+00, double* %14
  store double 1.000000e+00, double* %15
  %16 = getelementptr inbounds %literal, %literal* %13, i32 0, i32 1
  %17 = load double, double* %16
  %18 = fptosi double %17 to i1
  br i1 %18, label %tenary.true, label %tenary.false

tenary.true:                                      ; preds = %entry
  %19 = call i8* @malloc(i32 16)
  %20 = bitcast i8* %19 to %literal*
  %21 = getelementptr inbounds %literal, %literal* %20, i32 0, i32 0
  %22 = getelementptr inbounds %literal, %literal* %20, i32 0, i32 1
  store double 2.000000e+00, double* %21
  store double 0.000000e+00, double* %22
  %23 = getelementptr inbounds %literal, %literal* %20, i32 0, i32 0
  %24 = getelementptr inbounds %literal, %literal* %20, i32 0, i32 1
  %25 = load double, double* %23
  %26 = load double, double* %24
  %27 = fcmp oeq double %25, 2.000000e+00
  br i1 %27, label %tc.valid, label %tc.error

tenary.false:                                     ; preds = %entry
  %28 = call i8* @malloc(i32 16)
  %29 = bitcast i8* %28 to %literal*
  %30 = getelementptr inbounds %literal, %literal* %29, i32 0, i32 0
  %31 = getelementptr inbounds %literal, %literal* %29, i32 0, i32 1
  store double 1.000000e+00, double* %30
  store double 3.000000e+00, double* %31
  br label %tenary.end

tenary.end:                                       ; preds = %tenary.false, %tenary.end4
  %32 = phi %literal* [ %52, %tenary.end4 ], [ %29, %tenary.false ]
  %33 = getelementptr inbounds %literal*, %literal** %5, i32 1
  store %literal* %32, %literal** %33
  call void @display(%literal* %32)
  ret i32 0

tc.error:                                         ; preds = %tenary.true
  call void @error(i8* getelementptr inbounds ([18 x i8], [18 x i8]* @0, i32 0, i32 0))
  call void @exit(i32 1)
  br label %tc.valid

tc.valid:                                         ; preds = %tc.error, %tenary.true
  %34 = fptosi double %26 to i1
  %35 = xor i1 %34, true
  %36 = uitofp i1 %35 to double
  %37 = call i8* @malloc(i32 16)
  %38 = bitcast i8* %37 to %literal*
  %39 = getelementptr inbounds %literal, %literal* %38, i32 0, i32 0
  %40 = getelementptr inbounds %literal, %literal* %38, i32 0, i32 1
  store double 2.000000e+00, double* %39
  store double %36, double* %40
  %41 = getelementptr inbounds %literal, %literal* %38, i32 0, i32 1
  %42 = load double, double* %41
  %43 = fptosi double %42 to i1
  br i1 %43, label %tenary.true2, label %tenary.false3

tenary.true2:                                     ; preds = %tc.valid
  %44 = call i8* @malloc(i32 16)
  %45 = bitcast i8* %44 to %literal*
  %46 = getelementptr inbounds %literal, %literal* %45, i32 0, i32 0
  %47 = getelementptr inbounds %literal, %literal* %45, i32 0, i32 1
  store double 1.000000e+00, double* %46
  store double 1.000000e+00, double* %47
  br label %tenary.end4

tenary.false3:                                    ; preds = %tc.valid
  %48 = call i8* @malloc(i32 16)
  %49 = bitcast i8* %48 to %literal*
  %50 = getelementptr inbounds %literal, %literal* %49, i32 0, i32 0
  %51 = getelementptr inbounds %literal, %literal* %49, i32 0, i32 1
  store double 1.000000e+00, double* %50
  store double 2.000000e+00, double* %51
  br label %tenary.end4

tenary.end4:                                      ; preds = %tenary.false3, %tenary.true2
  %52 = phi %literal* [ %45, %tenary.true2 ], [ %49, %tenary.false3 ]
  br label %tenary.end
}

