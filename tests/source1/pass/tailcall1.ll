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
  store %literal* (%literal**, %literal**)* @__fact, %literal* (%literal**, %literal**)** %16
  %17 = bitcast %function_literal* %13 to %literal*
  %18 = getelementptr inbounds %literal*, %literal** %5, i32 1
  store %literal* %17, %literal** %18
  %19 = call i8* @malloc(i32 16)
  %20 = bitcast i8* %19 to %literal*
  %21 = getelementptr inbounds %literal, %literal* %20, i32 0, i32 0
  %22 = getelementptr inbounds %literal, %literal* %20, i32 0, i32 1
  store double 1.000000e+00, double* %21
  store double 5.000000e+00, double* %22
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
  call void @error(i8* getelementptr inbounds ([18 x i8], [18 x i8]* @3, i32 0, i32 0))
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

define %literal* @__fact(%literal** %0, %literal** %1) {
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

f.entry:                                          ; preds = %tc.valid9, %f.setup
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
  br i1 %42, label %if.true, label %if.false

if.true:                                          ; preds = %tc.valid
  %env2 = call i8* @malloc(i32 8)
  %43 = bitcast i8* %env2 to %literal**
  %44 = bitcast %literal** %43 to %literal***
  store %literal** %10, %literal*** %44
  %45 = bitcast %literal** %43 to %literal***
  %46 = load %literal**, %literal*** %45
  %47 = bitcast %literal** %46 to %literal***
  %48 = load %literal**, %literal*** %47
  %49 = getelementptr inbounds %literal*, %literal** %48, i32 2
  %50 = load %literal*, %literal** %49
  ret %literal* %50

if.false:                                         ; preds = %tc.valid
  %env3 = call i8* @malloc(i32 8)
  %51 = bitcast i8* %env3 to %literal**
  %52 = bitcast %literal** %51 to %literal***
  store %literal** %10, %literal*** %52
  %53 = bitcast %literal** %51 to %literal***
  %54 = load %literal**, %literal*** %53
  %55 = bitcast %literal** %54 to %literal***
  %56 = load %literal**, %literal*** %55
  %57 = getelementptr inbounds %literal*, %literal** %56, i32 1
  %58 = load %literal*, %literal** %57
  %59 = call i8* @malloc(i32 16)
  %60 = bitcast i8* %59 to %literal*
  %61 = getelementptr inbounds %literal, %literal* %60, i32 0, i32 0
  %62 = getelementptr inbounds %literal, %literal* %60, i32 0, i32 1
  store double 1.000000e+00, double* %61
  store double 1.000000e+00, double* %62
  %63 = getelementptr inbounds %literal, %literal* %58, i32 0, i32 1
  %64 = getelementptr inbounds %literal, %literal* %60, i32 0, i32 1
  %65 = load double, double* %63
  %66 = load double, double* %64
  %67 = getelementptr inbounds %literal, %literal* %58, i32 0, i32 0
  %68 = getelementptr inbounds %literal, %literal* %60, i32 0, i32 0
  %69 = load double, double* %67
  %70 = load double, double* %68
  %71 = fcmp oeq double %69, 1.000000e+00
  br i1 %71, label %tc.next4, label %tc.error5

if.end:                                           ; No predecessors!
  ret %literal* %13

tc.next4:                                         ; preds = %if.false
  %72 = fcmp oeq double %70, 1.000000e+00
  br i1 %72, label %tc.valid6, label %tc.error5

tc.error5:                                        ; preds = %tc.next4, %if.false
  call void @error(i8* getelementptr inbounds ([18 x i8], [18 x i8]* @1, i32 0, i32 0))
  call void @exit(i32 1)
  br label %tc.valid6

tc.valid6:                                        ; preds = %tc.error5, %tc.next4
  %73 = fsub double %65, %66
  %74 = call i8* @malloc(i32 16)
  %75 = bitcast i8* %74 to %literal*
  %76 = getelementptr inbounds %literal, %literal* %75, i32 0, i32 0
  %77 = getelementptr inbounds %literal, %literal* %75, i32 0, i32 1
  store double 1.000000e+00, double* %76
  store double %73, double* %77
  %78 = bitcast %literal** %51 to %literal***
  %79 = load %literal**, %literal*** %78
  %80 = bitcast %literal** %79 to %literal***
  %81 = load %literal**, %literal*** %80
  %82 = getelementptr inbounds %literal*, %literal** %81, i32 1
  %83 = load %literal*, %literal** %82
  %84 = bitcast %literal** %51 to %literal***
  %85 = load %literal**, %literal*** %84
  %86 = bitcast %literal** %85 to %literal***
  %87 = load %literal**, %literal*** %86
  %88 = getelementptr inbounds %literal*, %literal** %87, i32 2
  %89 = load %literal*, %literal** %88
  %90 = getelementptr inbounds %literal, %literal* %83, i32 0, i32 1
  %91 = getelementptr inbounds %literal, %literal* %89, i32 0, i32 1
  %92 = load double, double* %90
  %93 = load double, double* %91
  %94 = getelementptr inbounds %literal, %literal* %83, i32 0, i32 0
  %95 = getelementptr inbounds %literal, %literal* %89, i32 0, i32 0
  %96 = load double, double* %94
  %97 = load double, double* %95
  %98 = fcmp oeq double %96, 1.000000e+00
  br i1 %98, label %tc.next7, label %tc.error8

tc.next7:                                         ; preds = %tc.valid6
  %99 = fcmp oeq double %97, 1.000000e+00
  br i1 %99, label %tc.valid9, label %tc.error8

tc.error8:                                        ; preds = %tc.next7, %tc.valid6
  call void @error(i8* getelementptr inbounds ([18 x i8], [18 x i8]* @2, i32 0, i32 0))
  call void @exit(i32 1)
  br label %tc.valid9

tc.valid9:                                        ; preds = %tc.error8, %tc.next7
  %100 = fmul double %92, %93
  %101 = call i8* @malloc(i32 16)
  %102 = bitcast i8* %101 to %literal*
  %103 = getelementptr inbounds %literal, %literal* %102, i32 0, i32 0
  %104 = getelementptr inbounds %literal, %literal* %102, i32 0, i32 1
  store double 1.000000e+00, double* %103
  store double %100, double* %104
  %105 = getelementptr inbounds %literal*, %literal** %2, i32 1
  store %literal* %75, %literal** %105
  %106 = getelementptr inbounds %literal*, %literal** %2, i32 2
  store %literal* %102, %literal** %106
  br label %f.entry
}

