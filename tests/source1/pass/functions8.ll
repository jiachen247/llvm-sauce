; ModuleID = 'module'
source_filename = "module"

%literal = type { double, double }
%function_literal = type { double, %literal**, %literal* (%literal**, %literal**)* }

@format_number = private unnamed_addr constant [5 x i8] c"%lf\0A\00", align 1
@format_true = private unnamed_addr constant [6 x i8] c"true\0A\00", align 1
@format_false = private unnamed_addr constant [7 x i8] c"false\0A\00", align 1
@format_string = private unnamed_addr constant [6 x i8] c"\22%s\22\0A\00", align 1
@format_function = private unnamed_addr constant [17 x i8] c"function object\0A\00", align 1
@format_undef = private unnamed_addr constant [11 x i8] c"undefined\0A\00", align 1
@format_error = private unnamed_addr constant [13 x i8] c"error: \22%s\22\0A\00", align 1
@0 = private unnamed_addr constant [18 x i8] c"boo type mismatch\00", align 1
@1 = private unnamed_addr constant [18 x i8] c"boo type mismatch\00", align 1
@2 = private unnamed_addr constant [18 x i8] c"boo type mismatch\00", align 1
@3 = private unnamed_addr constant [18 x i8] c"boo type mismatch\00", align 1
@4 = private unnamed_addr constant [18 x i8] c"boo type mismatch\00", align 1

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
  store volatile %literal* %8, %literal** %11
  %12 = call i8* @malloc(i32 16)
  %13 = bitcast i8* %12 to %function_literal*
  %14 = getelementptr inbounds %function_literal, %function_literal* %13, i32 0, i32 0
  %15 = getelementptr inbounds %function_literal, %function_literal* %13, i32 0, i32 1
  %16 = getelementptr inbounds %function_literal, %function_literal* %13, i32 0, i32 2
  store double 4.000000e+00, double* %14
  store %literal** %5, %literal*** %15
  store %literal* (%literal**, %literal**)* @__factorial, %literal* (%literal**, %literal**)** %16
  %17 = bitcast %function_literal* %13 to %literal*
  %18 = getelementptr inbounds %literal*, %literal** %5, i32 1
  store %literal* %17, %literal** %18
  %19 = call i8* @malloc(i32 16)
  %20 = bitcast i8* %19 to %literal*
  %21 = getelementptr inbounds %literal, %literal* %20, i32 0, i32 0
  %22 = getelementptr inbounds %literal, %literal* %20, i32 0, i32 1
  store double 1.000000e+00, double* %21
  store double 1.000000e+01, double* %22
  %23 = call i8* @malloc(i32 16)
  %24 = bitcast i8* %23 to %literal*
  %25 = getelementptr inbounds %literal, %literal* %24, i32 0, i32 0
  %26 = getelementptr inbounds %literal, %literal* %24, i32 0, i32 1
  store double 1.000000e+00, double* %25
  store double 1.000000e+00, double* %26
  %27 = getelementptr inbounds %literal*, %literal** %5, i32 1
  %28 = load %literal*, %literal** %27
  %29 = getelementptr inbounds %literal, %literal* %28, i32 0, i32 0
  %30 = load double, double* %29
  %31 = fcmp oeq double %30, 4.000000e+00
  br i1 %31, label %next, label %error

error:                                            ; preds = %entry
  call void @error(i8* getelementptr inbounds ([18 x i8], [18 x i8]* @4, i32 0, i32 0))
  call void @exit(i32 1)
  br label %next

next:                                             ; preds = %error, %entry
  %32 = bitcast %literal* %28 to %function_literal*
  %33 = getelementptr inbounds %function_literal, %function_literal* %32, i32 0, i32 2
  %34 = load %literal* (%literal**, %literal**)*, %literal* (%literal**, %literal**)** %33
  %35 = getelementptr inbounds %function_literal, %function_literal* %32, i32 0, i32 1
  %36 = load %literal**, %literal*** %35
  %params = call i8* @malloc(i32 16)
  %37 = bitcast i8* %params to %literal**
  %38 = getelementptr inbounds %literal*, %literal** %37, i32 0
  store %literal* %20, %literal** %38
  %39 = getelementptr inbounds %literal*, %literal** %37, i32 1
  store %literal* %24, %literal** %39
  %40 = call %literal* %34(%literal** %36, %literal** %37)
  call void @display(%literal* %40)
  ret i32 0
}

define %literal* @__factorial(%literal** %0, %literal** %1) {
f.setup:
  %env = call i8* @malloc(i32 24)
  %2 = bitcast i8* %env to %literal**
  %3 = bitcast %literal** %2 to %literal***
  store %literal** %0, %literal*** %3
  %4 = getelementptr inbounds %literal*, %literal** %1, i32 0
  %5 = load %literal*, %literal** %4
  %6 = getelementptr inbounds %literal*, %literal** %2, i32 1
  store %literal* %5, %literal** %6
  %7 = getelementptr inbounds %literal*, %literal** %1, i32 1
  %8 = load %literal*, %literal** %7
  %9 = getelementptr inbounds %literal*, %literal** %2, i32 2
  store %literal* %8, %literal** %9
  br label %f.entry

f.entry:                                          ; preds = %f.setup
  %env1 = call i8* @malloc(i32 8)
  %10 = bitcast i8* %env1 to %literal**
  %11 = bitcast %literal** %10 to %literal***
  store %literal** %2, %literal*** %11
  %12 = call i8* @malloc(i32 16)
  %13 = bitcast i8* %12 to %literal*
  %14 = getelementptr inbounds %literal, %literal* %13, i32 0, i32 0
  %15 = getelementptr inbounds %literal, %literal* %13, i32 0, i32 1
  store double 5.000000e+00, double* %14
  store double 0.000000e+00, double* %15
  %16 = bitcast %literal** %10 to %literal***
  %17 = load %literal**, %literal*** %16
  %18 = getelementptr inbounds %literal*, %literal** %17, i32 1
  %19 = load %literal*, %literal** %18
  %20 = call i8* @malloc(i32 16)
  %21 = bitcast i8* %20 to %literal*
  %22 = getelementptr inbounds %literal, %literal* %21, i32 0, i32 0
  %23 = getelementptr inbounds %literal, %literal* %21, i32 0, i32 1
  store double 1.000000e+00, double* %22
  store double 1.000000e+00, double* %23
  %24 = getelementptr inbounds %literal, %literal* %19, i32 0, i32 1
  %25 = getelementptr inbounds %literal, %literal* %21, i32 0, i32 1
  %26 = load double, double* %24
  %27 = load double, double* %25
  %28 = getelementptr inbounds %literal, %literal* %19, i32 0, i32 0
  %29 = getelementptr inbounds %literal, %literal* %21, i32 0, i32 0
  %30 = load double, double* %28
  %31 = load double, double* %29
  %32 = fcmp oeq double %30, 1.000000e+00
  br i1 %32, label %tc.next, label %tc.error

tc.next:                                          ; preds = %f.entry
  %33 = fcmp oeq double %31, 1.000000e+00
  br i1 %33, label %tc.valid, label %tc.error

tc.error:                                         ; preds = %tc.next, %f.entry
  call void @error(i8* getelementptr inbounds ([18 x i8], [18 x i8]* @0, i32 0, i32 0))
  call void @exit(i32 1)
  br label %tc.valid

tc.valid:                                         ; preds = %tc.error, %tc.next
  %34 = fcmp oeq double %26, %27
  %35 = uitofp i1 %34 to double
  %36 = call i8* @malloc(i32 16)
  %37 = bitcast i8* %36 to %literal*
  %38 = getelementptr inbounds %literal, %literal* %37, i32 0, i32 0
  %39 = getelementptr inbounds %literal, %literal* %37, i32 0, i32 1
  store double 2.000000e+00, double* %38
  store double %35, double* %39
  %40 = getelementptr inbounds %literal, %literal* %37, i32 0, i32 1
  %41 = load double, double* %40
  %42 = fptosi double %41 to i1
  br i1 %42, label %tenary.true, label %tenary.false

tenary.true:                                      ; preds = %tc.valid
  %43 = bitcast %literal** %10 to %literal***
  %44 = load %literal**, %literal*** %43
  %45 = getelementptr inbounds %literal*, %literal** %44, i32 2
  %46 = load %literal*, %literal** %45
  br label %tenary.end

tenary.false:                                     ; preds = %tc.valid
  %47 = bitcast %literal** %10 to %literal***
  %48 = load %literal**, %literal*** %47
  %49 = getelementptr inbounds %literal*, %literal** %48, i32 1
  %50 = load %literal*, %literal** %49
  %51 = call i8* @malloc(i32 16)
  %52 = bitcast i8* %51 to %literal*
  %53 = getelementptr inbounds %literal, %literal* %52, i32 0, i32 0
  %54 = getelementptr inbounds %literal, %literal* %52, i32 0, i32 1
  store double 1.000000e+00, double* %53
  store double 1.000000e+00, double* %54
  %55 = getelementptr inbounds %literal, %literal* %50, i32 0, i32 1
  %56 = getelementptr inbounds %literal, %literal* %52, i32 0, i32 1
  %57 = load double, double* %55
  %58 = load double, double* %56
  %59 = getelementptr inbounds %literal, %literal* %50, i32 0, i32 0
  %60 = getelementptr inbounds %literal, %literal* %52, i32 0, i32 0
  %61 = load double, double* %59
  %62 = load double, double* %60
  %63 = fcmp oeq double %61, 1.000000e+00
  br i1 %63, label %tc.next2, label %tc.error3

tenary.end:                                       ; preds = %next, %tenary.true
  %64 = phi %literal* [ %46, %tenary.true ], [ %111, %next ]
  ret %literal* %64

tc.next2:                                         ; preds = %tenary.false
  %65 = fcmp oeq double %62, 1.000000e+00
  br i1 %65, label %tc.valid4, label %tc.error3

tc.error3:                                        ; preds = %tc.next2, %tenary.false
  call void @error(i8* getelementptr inbounds ([18 x i8], [18 x i8]* @1, i32 0, i32 0))
  call void @exit(i32 1)
  br label %tc.valid4

tc.valid4:                                        ; preds = %tc.error3, %tc.next2
  %66 = fsub double %57, %58
  %67 = call i8* @malloc(i32 16)
  %68 = bitcast i8* %67 to %literal*
  %69 = getelementptr inbounds %literal, %literal* %68, i32 0, i32 0
  %70 = getelementptr inbounds %literal, %literal* %68, i32 0, i32 1
  store double 1.000000e+00, double* %69
  store double %66, double* %70
  %71 = bitcast %literal** %10 to %literal***
  %72 = load %literal**, %literal*** %71
  %73 = getelementptr inbounds %literal*, %literal** %72, i32 1
  %74 = load %literal*, %literal** %73
  %75 = bitcast %literal** %10 to %literal***
  %76 = load %literal**, %literal*** %75
  %77 = getelementptr inbounds %literal*, %literal** %76, i32 2
  %78 = load %literal*, %literal** %77
  %79 = getelementptr inbounds %literal, %literal* %74, i32 0, i32 1
  %80 = getelementptr inbounds %literal, %literal* %78, i32 0, i32 1
  %81 = load double, double* %79
  %82 = load double, double* %80
  %83 = getelementptr inbounds %literal, %literal* %74, i32 0, i32 0
  %84 = getelementptr inbounds %literal, %literal* %78, i32 0, i32 0
  %85 = load double, double* %83
  %86 = load double, double* %84
  %87 = fcmp oeq double %85, 1.000000e+00
  br i1 %87, label %tc.next5, label %tc.error6

tc.next5:                                         ; preds = %tc.valid4
  %88 = fcmp oeq double %86, 1.000000e+00
  br i1 %88, label %tc.valid7, label %tc.error6

tc.error6:                                        ; preds = %tc.next5, %tc.valid4
  call void @error(i8* getelementptr inbounds ([18 x i8], [18 x i8]* @2, i32 0, i32 0))
  call void @exit(i32 1)
  br label %tc.valid7

tc.valid7:                                        ; preds = %tc.error6, %tc.next5
  %89 = fmul double %81, %82
  %90 = call i8* @malloc(i32 16)
  %91 = bitcast i8* %90 to %literal*
  %92 = getelementptr inbounds %literal, %literal* %91, i32 0, i32 0
  %93 = getelementptr inbounds %literal, %literal* %91, i32 0, i32 1
  store double 1.000000e+00, double* %92
  store double %89, double* %93
  %94 = bitcast %literal** %10 to %literal***
  %95 = load %literal**, %literal*** %94
  %96 = bitcast %literal** %95 to %literal***
  %97 = load %literal**, %literal*** %96
  %98 = getelementptr inbounds %literal*, %literal** %97, i32 1
  %99 = load %literal*, %literal** %98
  %100 = getelementptr inbounds %literal, %literal* %99, i32 0, i32 0
  %101 = load double, double* %100
  %102 = fcmp oeq double %101, 4.000000e+00
  br i1 %102, label %next, label %error

error:                                            ; preds = %tc.valid7
  call void @error(i8* getelementptr inbounds ([18 x i8], [18 x i8]* @3, i32 0, i32 0))
  call void @exit(i32 1)
  br label %next

next:                                             ; preds = %error, %tc.valid7
  %103 = bitcast %literal* %99 to %function_literal*
  %104 = getelementptr inbounds %function_literal, %function_literal* %103, i32 0, i32 2
  %105 = load %literal* (%literal**, %literal**)*, %literal* (%literal**, %literal**)** %104
  %106 = getelementptr inbounds %function_literal, %function_literal* %103, i32 0, i32 1
  %107 = load %literal**, %literal*** %106
  %params = call i8* @malloc(i32 16)
  %108 = bitcast i8* %params to %literal**
  %109 = getelementptr inbounds %literal*, %literal** %108, i32 0
  store %literal* %68, %literal** %109
  %110 = getelementptr inbounds %literal*, %literal** %108, i32 1
  store %literal* %91, %literal** %110
  %111 = call %literal* %105(%literal** %107, %literal** %108)
  br label %tenary.end
}

