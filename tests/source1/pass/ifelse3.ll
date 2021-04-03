; ModuleID = 'module'
source_filename = "module"

%literal = type { double, double }
%string_literal = type { double, i8* }

@format_number = private unnamed_addr constant [5 x i8] c"%lf\0A\00", align 1
@format_true = private unnamed_addr constant [6 x i8] c"true\0A\00", align 1
@format_false = private unnamed_addr constant [7 x i8] c"false\0A\00", align 1
@format_string = private unnamed_addr constant [6 x i8] c"\22%s\22\0A\00", align 1
@format_function = private unnamed_addr constant [17 x i8] c"function object\0A\00", align 1
@format_undef = private unnamed_addr constant [11 x i8] c"undefined\0A\00", align 1
@format_error = private unnamed_addr constant [13 x i8] c"error: \22%s\22\0A\00", align 1
@0 = private unnamed_addr constant [18 x i8] c"boo type mismatch\00", align 1
@1 = private unnamed_addr constant [18 x i8] c"boo type mismatch\00", align 1

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
  store double 1.000000e+00, double* %13
  store double 1.000000e+00, double* %14
  %15 = call i8* @malloc(i32 16)
  %16 = bitcast i8* %15 to %literal*
  %17 = getelementptr inbounds %literal, %literal* %16, i32 0, i32 0
  %18 = getelementptr inbounds %literal, %literal* %16, i32 0, i32 1
  store double 1.000000e+00, double* %17
  store double 1.000000e+00, double* %18
  %19 = getelementptr inbounds %literal, %literal* %12, i32 0, i32 1
  %20 = getelementptr inbounds %literal, %literal* %16, i32 0, i32 1
  %21 = load double, double* %19
  %22 = load double, double* %20
  %23 = getelementptr inbounds %literal, %literal* %12, i32 0, i32 0
  %24 = getelementptr inbounds %literal, %literal* %16, i32 0, i32 0
  %25 = load double, double* %23
  %26 = load double, double* %24
  %27 = fcmp oeq double %25, 1.000000e+00
  br i1 %27, label %add.num1, label %add.cstr1

add.num1:                                         ; preds = %entry
  %28 = fcmp oeq double %26, 1.000000e+00
  br i1 %28, label %add.num, label %add.err

add.cstr1:                                        ; preds = %entry
  %29 = fcmp oeq double %25, 3.000000e+00
  br i1 %29, label %add.cstr2, label %add.err

add.cstr2:                                        ; preds = %add.cstr1
  %30 = fcmp oeq double %26, 3.000000e+00
  br i1 %30, label %add.str, label %add.err

add.err:                                          ; preds = %add.cstr2, %add.cstr1, %add.num1
  call void @error(i8* getelementptr inbounds ([18 x i8], [18 x i8]* @0, i32 0, i32 0))
  call void @exit(i32 1)
  br label %add.num

add.num:                                          ; preds = %add.err, %add.num1
  %31 = load double, double* %19
  %32 = load double, double* %20
  %33 = fadd double %31, %32
  %34 = call i8* @malloc(i32 16)
  %35 = bitcast i8* %34 to %literal*
  %36 = getelementptr inbounds %literal, %literal* %35, i32 0, i32 0
  %37 = getelementptr inbounds %literal, %literal* %35, i32 0, i32 1
  store double 1.000000e+00, double* %36
  store double %33, double* %37
  br label %add.end

add.str:                                          ; preds = %add.cstr2
  %38 = bitcast %literal* %12 to %string_literal*
  %39 = bitcast %literal* %16 to %string_literal*
  %40 = getelementptr inbounds %string_literal, %string_literal* %38, i32 0, i32 1
  %41 = getelementptr inbounds %string_literal, %string_literal* %39, i32 0, i32 1
  %42 = load i8*, i8** %40
  %43 = load i8*, i8** %41
  %44 = call i8* @strconcat(i8* %42, i8* %43)
  %45 = call i8* @malloc(i32 16)
  %46 = bitcast i8* %45 to %string_literal*
  %47 = getelementptr inbounds %string_literal, %string_literal* %46, i32 0, i32 0
  %48 = getelementptr inbounds %string_literal, %string_literal* %46, i32 0, i32 1
  store double 3.000000e+00, double* %47
  store i8* %44, i8** %48
  %49 = bitcast %string_literal* %46 to %literal*
  br label %add.end

add.end:                                          ; preds = %add.str, %add.num
  %50 = phi %literal* [ %35, %add.num ], [ %49, %add.str ]
  %51 = call i8* @malloc(i32 16)
  %52 = bitcast i8* %51 to %literal*
  %53 = getelementptr inbounds %literal, %literal* %52, i32 0, i32 0
  %54 = getelementptr inbounds %literal, %literal* %52, i32 0, i32 1
  store double 1.000000e+00, double* %53
  store double 2.000000e+00, double* %54
  %55 = getelementptr inbounds %literal, %literal* %50, i32 0, i32 1
  %56 = getelementptr inbounds %literal, %literal* %52, i32 0, i32 1
  %57 = load double, double* %55
  %58 = load double, double* %56
  %59 = getelementptr inbounds %literal, %literal* %50, i32 0, i32 0
  %60 = getelementptr inbounds %literal, %literal* %52, i32 0, i32 0
  %61 = load double, double* %59
  %62 = load double, double* %60
  %63 = fcmp oeq double %61, 1.000000e+00
  br i1 %63, label %tc.next, label %tc.error

tc.next:                                          ; preds = %add.end
  %64 = fcmp oeq double %62, 1.000000e+00
  br i1 %64, label %tc.valid, label %tc.error

tc.error:                                         ; preds = %tc.next, %add.end
  call void @error(i8* getelementptr inbounds ([18 x i8], [18 x i8]* @1, i32 0, i32 0))
  call void @exit(i32 1)
  br label %tc.valid

tc.valid:                                         ; preds = %tc.error, %tc.next
  %65 = fcmp ogt double %57, %58
  %66 = uitofp i1 %65 to double
  %67 = call i8* @malloc(i32 16)
  %68 = bitcast i8* %67 to %literal*
  %69 = getelementptr inbounds %literal, %literal* %68, i32 0, i32 0
  %70 = getelementptr inbounds %literal, %literal* %68, i32 0, i32 1
  store double 2.000000e+00, double* %69
  store double %66, double* %70
  %71 = getelementptr inbounds %literal, %literal* %68, i32 0, i32 1
  %72 = load double, double* %71
  %73 = fptosi double %72 to i1
  br i1 %73, label %if.true, label %if.false

if.true:                                          ; preds = %tc.valid
  %env2 = call i8* @malloc(i32 8)
  %74 = bitcast i8* %env2 to %literal**
  %75 = bitcast %literal** %74 to %literal***
  store %literal** %5, %literal*** %75
  %76 = call i8* @malloc(i32 16)
  %77 = bitcast i8* %76 to %literal*
  %78 = getelementptr inbounds %literal, %literal* %77, i32 0, i32 0
  %79 = getelementptr inbounds %literal, %literal* %77, i32 0, i32 1
  store double 1.000000e+00, double* %78
  store double 1.000000e+00, double* %79
  call void @display(%literal* %77)
  br label %if.end

if.false:                                         ; preds = %tc.valid
  %env3 = call i8* @malloc(i32 8)
  %80 = bitcast i8* %env3 to %literal**
  %81 = bitcast %literal** %80 to %literal***
  store %literal** %5, %literal*** %81
  %82 = call i8* @malloc(i32 16)
  %83 = bitcast i8* %82 to %literal*
  %84 = getelementptr inbounds %literal, %literal* %83, i32 0, i32 0
  %85 = getelementptr inbounds %literal, %literal* %83, i32 0, i32 1
  store double 1.000000e+00, double* %84
  store double 2.000000e+00, double* %85
  call void @display(%literal* %83)
  br label %if.end

if.end:                                           ; preds = %if.false, %if.true
  ret i32 0
}

