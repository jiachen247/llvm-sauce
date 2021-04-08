; ModuleID = 'module'
source_filename = "module"

%literal = type { double, double }
%function_literal = type { double, %literal**, %literal* (%literal**, %literal**)* }
%string_literal = type { double, i8* }

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
  %13 = bitcast i8* %12 to %function_literal*
  %14 = getelementptr inbounds %function_literal, %function_literal* %13, i32 0, i32 0
  %15 = getelementptr inbounds %function_literal, %function_literal* %13, i32 0, i32 1
  %16 = getelementptr inbounds %function_literal, %function_literal* %13, i32 0, i32 2
  store double 4.000000e+00, double* %14
  store %literal** %5, %literal*** %15
  store %literal* (%literal**, %literal**)* @__fib, %literal* (%literal**, %literal**)** %16
  %17 = bitcast %function_literal* %13 to %literal*
  %18 = getelementptr inbounds %literal*, %literal** %5, i32 1
  store %literal* %17, %literal** %18
  %19 = call i8* @malloc(i32 16)
  %20 = bitcast i8* %19 to %literal*
  %21 = getelementptr inbounds %literal, %literal* %20, i32 0, i32 0
  %22 = getelementptr inbounds %literal, %literal* %20, i32 0, i32 1
  store double 1.000000e+00, double* %21
  store double 2.000000e+01, double* %22
  %23 = getelementptr inbounds %literal, %literal* %17, i32 0, i32 0
  %24 = load double, double* %23
  %25 = fcmp oeq double %24, 4.000000e+00
  br i1 %25, label %next, label %error

error:                                            ; preds = %entry
  call void @error(i8* getelementptr inbounds ([18 x i8], [18 x i8]* @0, i32 0, i32 0))
  call void @exit(i32 1)
  br label %next

next:                                             ; preds = %error, %entry
  %26 = bitcast %literal* %17 to %function_literal*
  %27 = getelementptr inbounds %function_literal, %function_literal* %26, i32 0, i32 2
  %28 = load %literal* (%literal**, %literal**)*, %literal* (%literal**, %literal**)** %27
  %29 = getelementptr inbounds %function_literal, %function_literal* %26, i32 0, i32 1
  %30 = load %literal**, %literal*** %29
  %params = call i8* @malloc(i32 8)
  %31 = bitcast i8* %params to %literal**
  %32 = getelementptr inbounds %literal*, %literal** %31, i32 0
  store %literal* %20, %literal** %32
  %33 = call %literal* %28(%literal** %30, %literal** %31)
  call void @display(%literal* %33)
  ret i32 0
}

define %literal* @__fib(%literal** %0, %literal** %1) {
f.setup:
  %env = call i8* @malloc(i32 16)
  %2 = bitcast i8* %env to %literal**
  %3 = bitcast %literal** %2 to %literal***
  store %literal** %0, %literal*** %3
  %4 = getelementptr inbounds %literal*, %literal** %1, i32 0
  %5 = load %literal*, %literal** %4
  %6 = getelementptr inbounds %literal*, %literal** %2, i32 1
  store %literal* %5, %literal** %6
  br label %f.entry

f.entry:                                          ; preds = %f.setup
  %env1 = call i8* @malloc(i32 8)
  %7 = bitcast i8* %env1 to %literal**
  %8 = bitcast %literal** %7 to %literal***
  store %literal** %2, %literal*** %8
  %9 = call i8* @malloc(i32 16)
  %10 = bitcast i8* %9 to %literal*
  %11 = getelementptr inbounds %literal, %literal* %10, i32 0, i32 0
  %12 = getelementptr inbounds %literal, %literal* %10, i32 0, i32 1
  store double 5.000000e+00, double* %11
  store double 0.000000e+00, double* %12
  %13 = call i8* @malloc(i32 16)
  %14 = bitcast i8* %13 to %literal*
  %15 = getelementptr inbounds %literal, %literal* %14, i32 0, i32 0
  %16 = getelementptr inbounds %literal, %literal* %14, i32 0, i32 1
  store double 1.000000e+00, double* %15
  store double 0.000000e+00, double* %16
  %17 = getelementptr inbounds %literal, %literal* %5, i32 0, i32 1
  %18 = getelementptr inbounds %literal, %literal* %14, i32 0, i32 1
  %19 = load double, double* %17
  %20 = load double, double* %18
  %21 = getelementptr inbounds %literal, %literal* %5, i32 0, i32 0
  %22 = getelementptr inbounds %literal, %literal* %14, i32 0, i32 0
  %23 = load double, double* %21
  %24 = load double, double* %22
  %25 = fcmp oeq double %23, 1.000000e+00
  br i1 %25, label %tc.next, label %tc.error

tc.next:                                          ; preds = %f.entry
  %26 = fcmp oeq double %24, 1.000000e+00
  br i1 %26, label %tc.valid, label %tc.error

tc.error:                                         ; preds = %tc.next, %f.entry
  call void @error(i8* getelementptr inbounds ([18 x i8], [18 x i8]* @0, i32 0, i32 0))
  call void @exit(i32 1)
  br label %tc.valid

tc.valid:                                         ; preds = %tc.error, %tc.next
  %27 = fcmp oeq double %19, %20
  %28 = uitofp i1 %27 to double
  %29 = call i8* @malloc(i32 16)
  %30 = bitcast i8* %29 to %literal*
  %31 = getelementptr inbounds %literal, %literal* %30, i32 0, i32 0
  %32 = getelementptr inbounds %literal, %literal* %30, i32 0, i32 1
  store double 2.000000e+00, double* %31
  store double %28, double* %32
  %33 = getelementptr inbounds %literal, %literal* %30, i32 0, i32 1
  %34 = load double, double* %33
  %35 = fptosi double %34 to i1
  br i1 %35, label %tenary.true, label %tenary.false

tenary.true:                                      ; preds = %tc.valid
  %36 = call i8* @malloc(i32 16)
  %37 = bitcast i8* %36 to %literal*
  %38 = getelementptr inbounds %literal, %literal* %37, i32 0, i32 0
  %39 = getelementptr inbounds %literal, %literal* %37, i32 0, i32 1
  store double 1.000000e+00, double* %38
  store double 0.000000e+00, double* %39
  br label %tenary.end

tenary.false:                                     ; preds = %tc.valid
  %40 = call i8* @malloc(i32 16)
  %41 = bitcast i8* %40 to %literal*
  %42 = getelementptr inbounds %literal, %literal* %41, i32 0, i32 0
  %43 = getelementptr inbounds %literal, %literal* %41, i32 0, i32 1
  store double 1.000000e+00, double* %42
  store double 1.000000e+00, double* %43
  %44 = getelementptr inbounds %literal, %literal* %5, i32 0, i32 1
  %45 = getelementptr inbounds %literal, %literal* %41, i32 0, i32 1
  %46 = load double, double* %44
  %47 = load double, double* %45
  %48 = getelementptr inbounds %literal, %literal* %5, i32 0, i32 0
  %49 = getelementptr inbounds %literal, %literal* %41, i32 0, i32 0
  %50 = load double, double* %48
  %51 = load double, double* %49
  %52 = fcmp oeq double %50, 1.000000e+00
  br i1 %52, label %tc.next2, label %tc.error3

tenary.end:                                       ; preds = %tenary.end7, %tenary.true
  %53 = phi %literal* [ %37, %tenary.true ], [ %81, %tenary.end7 ]
  ret %literal* %53

tc.next2:                                         ; preds = %tenary.false
  %54 = fcmp oeq double %51, 1.000000e+00
  br i1 %54, label %tc.valid4, label %tc.error3

tc.error3:                                        ; preds = %tc.next2, %tenary.false
  call void @error(i8* getelementptr inbounds ([18 x i8], [18 x i8]* @0, i32 0, i32 0))
  call void @exit(i32 1)
  br label %tc.valid4

tc.valid4:                                        ; preds = %tc.error3, %tc.next2
  %55 = fcmp oeq double %46, %47
  %56 = uitofp i1 %55 to double
  %57 = call i8* @malloc(i32 16)
  %58 = bitcast i8* %57 to %literal*
  %59 = getelementptr inbounds %literal, %literal* %58, i32 0, i32 0
  %60 = getelementptr inbounds %literal, %literal* %58, i32 0, i32 1
  store double 2.000000e+00, double* %59
  store double %56, double* %60
  %61 = getelementptr inbounds %literal, %literal* %58, i32 0, i32 1
  %62 = load double, double* %61
  %63 = fptosi double %62 to i1
  br i1 %63, label %tenary.true5, label %tenary.false6

tenary.true5:                                     ; preds = %tc.valid4
  %64 = call i8* @malloc(i32 16)
  %65 = bitcast i8* %64 to %literal*
  %66 = getelementptr inbounds %literal, %literal* %65, i32 0, i32 0
  %67 = getelementptr inbounds %literal, %literal* %65, i32 0, i32 1
  store double 1.000000e+00, double* %66
  store double 1.000000e+00, double* %67
  br label %tenary.end7

tenary.false6:                                    ; preds = %tc.valid4
  %68 = call i8* @malloc(i32 16)
  %69 = bitcast i8* %68 to %literal*
  %70 = getelementptr inbounds %literal, %literal* %69, i32 0, i32 0
  %71 = getelementptr inbounds %literal, %literal* %69, i32 0, i32 1
  store double 1.000000e+00, double* %70
  store double 1.000000e+00, double* %71
  %72 = getelementptr inbounds %literal, %literal* %5, i32 0, i32 1
  %73 = getelementptr inbounds %literal, %literal* %69, i32 0, i32 1
  %74 = load double, double* %72
  %75 = load double, double* %73
  %76 = getelementptr inbounds %literal, %literal* %5, i32 0, i32 0
  %77 = getelementptr inbounds %literal, %literal* %69, i32 0, i32 0
  %78 = load double, double* %76
  %79 = load double, double* %77
  %80 = fcmp oeq double %78, 1.000000e+00
  br i1 %80, label %tc.next8, label %tc.error9

tenary.end7:                                      ; preds = %add.end, %tenary.true5
  %81 = phi %literal* [ %65, %tenary.true5 ], [ %164, %add.end ]
  br label %tenary.end

tc.next8:                                         ; preds = %tenary.false6
  %82 = fcmp oeq double %79, 1.000000e+00
  br i1 %82, label %tc.valid10, label %tc.error9

tc.error9:                                        ; preds = %tc.next8, %tenary.false6
  call void @error(i8* getelementptr inbounds ([18 x i8], [18 x i8]* @0, i32 0, i32 0))
  call void @exit(i32 1)
  br label %tc.valid10

tc.valid10:                                       ; preds = %tc.error9, %tc.next8
  %83 = fsub double %74, %75
  %84 = call i8* @malloc(i32 16)
  %85 = bitcast i8* %84 to %literal*
  %86 = getelementptr inbounds %literal, %literal* %85, i32 0, i32 0
  %87 = getelementptr inbounds %literal, %literal* %85, i32 0, i32 1
  store double 1.000000e+00, double* %86
  store double %83, double* %87
  %88 = bitcast %literal** %2 to %literal***
  %89 = load %literal**, %literal*** %88
  %90 = getelementptr inbounds %literal*, %literal** %89, i32 1
  %91 = load %literal*, %literal** %90
  %92 = getelementptr inbounds %literal, %literal* %91, i32 0, i32 0
  %93 = load double, double* %92
  %94 = fcmp oeq double %93, 4.000000e+00
  br i1 %94, label %next, label %error

error:                                            ; preds = %tc.valid10
  call void @error(i8* getelementptr inbounds ([18 x i8], [18 x i8]* @0, i32 0, i32 0))
  call void @exit(i32 1)
  br label %next

next:                                             ; preds = %error, %tc.valid10
  %95 = bitcast %literal* %91 to %function_literal*
  %96 = getelementptr inbounds %function_literal, %function_literal* %95, i32 0, i32 2
  %97 = load %literal* (%literal**, %literal**)*, %literal* (%literal**, %literal**)** %96
  %98 = getelementptr inbounds %function_literal, %function_literal* %95, i32 0, i32 1
  %99 = load %literal**, %literal*** %98
  %params = call i8* @malloc(i32 8)
  %100 = bitcast i8* %params to %literal**
  %101 = getelementptr inbounds %literal*, %literal** %100, i32 0
  store %literal* %85, %literal** %101
  %102 = call %literal* %97(%literal** %99, %literal** %100)
  %103 = call i8* @malloc(i32 16)
  %104 = bitcast i8* %103 to %literal*
  %105 = getelementptr inbounds %literal, %literal* %104, i32 0, i32 0
  %106 = getelementptr inbounds %literal, %literal* %104, i32 0, i32 1
  store double 1.000000e+00, double* %105
  store double 2.000000e+00, double* %106
  %107 = getelementptr inbounds %literal, %literal* %5, i32 0, i32 1
  %108 = getelementptr inbounds %literal, %literal* %104, i32 0, i32 1
  %109 = load double, double* %107
  %110 = load double, double* %108
  %111 = getelementptr inbounds %literal, %literal* %5, i32 0, i32 0
  %112 = getelementptr inbounds %literal, %literal* %104, i32 0, i32 0
  %113 = load double, double* %111
  %114 = load double, double* %112
  %115 = fcmp oeq double %113, 1.000000e+00
  br i1 %115, label %tc.next11, label %tc.error12

tc.next11:                                        ; preds = %next
  %116 = fcmp oeq double %114, 1.000000e+00
  br i1 %116, label %tc.valid13, label %tc.error12

tc.error12:                                       ; preds = %tc.next11, %next
  call void @error(i8* getelementptr inbounds ([18 x i8], [18 x i8]* @0, i32 0, i32 0))
  call void @exit(i32 1)
  br label %tc.valid13

tc.valid13:                                       ; preds = %tc.error12, %tc.next11
  %117 = fsub double %109, %110
  %118 = call i8* @malloc(i32 16)
  %119 = bitcast i8* %118 to %literal*
  %120 = getelementptr inbounds %literal, %literal* %119, i32 0, i32 0
  %121 = getelementptr inbounds %literal, %literal* %119, i32 0, i32 1
  store double 1.000000e+00, double* %120
  store double %117, double* %121
  %122 = getelementptr inbounds %literal, %literal* %91, i32 0, i32 0
  %123 = load double, double* %122
  %124 = fcmp oeq double %123, 4.000000e+00
  br i1 %124, label %next15, label %error14

error14:                                          ; preds = %tc.valid13
  call void @error(i8* getelementptr inbounds ([18 x i8], [18 x i8]* @0, i32 0, i32 0))
  call void @exit(i32 1)
  br label %next15

next15:                                           ; preds = %error14, %tc.valid13
  %125 = bitcast %literal* %91 to %function_literal*
  %126 = getelementptr inbounds %function_literal, %function_literal* %125, i32 0, i32 2
  %127 = load %literal* (%literal**, %literal**)*, %literal* (%literal**, %literal**)** %126
  %128 = getelementptr inbounds %function_literal, %function_literal* %125, i32 0, i32 1
  %129 = load %literal**, %literal*** %128
  %params16 = call i8* @malloc(i32 8)
  %130 = bitcast i8* %params16 to %literal**
  %131 = getelementptr inbounds %literal*, %literal** %130, i32 0
  store %literal* %119, %literal** %131
  %132 = call %literal* %127(%literal** %129, %literal** %130)
  %133 = getelementptr inbounds %literal, %literal* %102, i32 0, i32 1
  %134 = getelementptr inbounds %literal, %literal* %132, i32 0, i32 1
  %135 = load double, double* %133
  %136 = load double, double* %134
  %137 = getelementptr inbounds %literal, %literal* %102, i32 0, i32 0
  %138 = getelementptr inbounds %literal, %literal* %132, i32 0, i32 0
  %139 = load double, double* %137
  %140 = load double, double* %138
  %141 = fcmp oeq double %139, 1.000000e+00
  br i1 %141, label %add.num1, label %add.cstr1

add.num1:                                         ; preds = %next15
  %142 = fcmp oeq double %140, 1.000000e+00
  br i1 %142, label %add.num, label %add.err

add.cstr1:                                        ; preds = %next15
  %143 = fcmp oeq double %139, 3.000000e+00
  br i1 %143, label %add.cstr2, label %add.err

add.cstr2:                                        ; preds = %add.cstr1
  %144 = fcmp oeq double %140, 3.000000e+00
  br i1 %144, label %add.str, label %add.err

add.err:                                          ; preds = %add.cstr2, %add.cstr1, %add.num1
  call void @error(i8* getelementptr inbounds ([18 x i8], [18 x i8]* @0, i32 0, i32 0))
  call void @exit(i32 1)
  br label %add.num

add.num:                                          ; preds = %add.err, %add.num1
  %145 = load double, double* %133
  %146 = load double, double* %134
  %147 = fadd double %145, %146
  %148 = call i8* @malloc(i32 16)
  %149 = bitcast i8* %148 to %literal*
  %150 = getelementptr inbounds %literal, %literal* %149, i32 0, i32 0
  %151 = getelementptr inbounds %literal, %literal* %149, i32 0, i32 1
  store double 1.000000e+00, double* %150
  store double %147, double* %151
  br label %add.end

add.str:                                          ; preds = %add.cstr2
  %152 = bitcast %literal* %102 to %string_literal*
  %153 = bitcast %literal* %132 to %string_literal*
  %154 = getelementptr inbounds %string_literal, %string_literal* %152, i32 0, i32 1
  %155 = getelementptr inbounds %string_literal, %string_literal* %153, i32 0, i32 1
  %156 = load i8*, i8** %154
  %157 = load i8*, i8** %155
  %158 = call i8* @strconcat(i8* %156, i8* %157)
  %159 = call i8* @malloc(i32 16)
  %160 = bitcast i8* %159 to %string_literal*
  %161 = getelementptr inbounds %string_literal, %string_literal* %160, i32 0, i32 0
  %162 = getelementptr inbounds %string_literal, %string_literal* %160, i32 0, i32 1
  store double 3.000000e+00, double* %161
  store i8* %158, i8** %162
  %163 = bitcast %string_literal* %160 to %literal*
  br label %add.end

add.end:                                          ; preds = %add.str, %add.num
  %164 = phi %literal* [ %149, %add.num ], [ %163, %add.str ]
  br label %tenary.end7
}

